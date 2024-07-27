//
//  FeedViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class FeedPageViewController: UIPageViewController {

    private var contentViewControllers: [FeedContentViewController] = []
    private let viewModel = FeedPageViewModel()
    private let disposeBag = DisposeBag() 
    
    private var currentIndex: Int = 0 // 현재 페이지 관리
    private var timer: Timer? // 프로그레스 바와 페이지 전환 제어
    private let progressBarMaxValue: Float = 5.0 // 5초. 프로그레스 바의 최대 값
    private var elapsedTime: Float = 0.0 // 경과 시간
    private var isLastPageReached = false // 마지막 페이지에 도달했는지
    private var isLoadingNextPage = false // 다음 페이지 로드 중인지
    private var lastViewedIndex: Int = 0 // 현재 페이지 인덱스를 저장할 변수

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        bind()
        setupTimer()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        invalidateTimer()
        self.dataSource = nil
        self.delegate = nil
    }

    private func bind() {
        let trigger = Observable.just(())
        
        let input = FeedPageViewModel.Input(trigger: trigger, fetchNextPage: Observable.never())
        let output = viewModel.transform(input: input)

        output.posts
            .drive(onNext: { [weak self] posts in
                self?.setupViewControllers(posts: posts)
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .drive(onNext: { [weak self] message in
                self?.view.makeToast(message, duration: 2.0, position: .center)
            })
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.lastViewedIndex < self.contentViewControllers.count {
                    self.setViewControllers([self.contentViewControllers[self.lastViewedIndex]], direction: .forward, animated: false, completion: nil)
                    self.resetTimerAndProgress()
                }
            })
            .disposed(by: disposeBag)
        
        self.rx.viewDidDisappear
            .subscribe(onNext: { [weak self] _ in
                self?.invalidateTimer() // 화면이 사라질 때 타이머 중지 및 해제
            })
            .disposed(by: disposeBag)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(willPresentModalViewController), name: .willPresentModalViewController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDismissModalViewController), name: .didDismissModalViewController, object: nil)
    }
    
    @objc private func willPresentModalViewController() {
        invalidateTimer()
        print("willPresentModalViewController")
    }
    
    @objc private func didDismissModalViewController() {
        if lastViewedIndex < contentViewControllers.count {
            print("didDismissModalViewController")
            setViewControllers([contentViewControllers[lastViewedIndex]], direction: .forward, animated: false, completion: nil)
            resetTimerAndProgress()
        }
    }

    private func setupTimer() {
        invalidateTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0.0
    }

    private func setupViewControllers(posts: [Post]) {
        self.contentViewControllers = posts.map { post in
            let vc = FeedContentViewController()
            vc.loadPost(post: post)
            vc.viewModel.postDeleteSuccess
                .subscribe(onNext: { [weak self] _ in
                    self?.moveToNextPage()
                })
                .disposed(by: vc.disposeBag)
            
            return vc
        }
        if let firstViewController = contentViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    private func moveToNextPage() {
        guard currentIndex < contentViewControllers.count else { return }

        contentViewControllers.remove(at: currentIndex) // 현재 페이지 삭제
        
        if contentViewControllers.isEmpty { return }
        
        currentIndex = currentIndex % contentViewControllers.count // 새 인덱스 계산
        let nextViewController = contentViewControllers[currentIndex]
        setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] completed in
            if completed {
                self?.resetTimerAndProgress() // 페이지 전환 완료 후 타이머 리셋
            }
        }
    }
    
    private func resetTimerAndProgress() {
        invalidateTimer()
        elapsedTime = 0
        
        guard lastViewedIndex < contentViewControllers.count else { return }
        
        isLastPageReached = (lastViewedIndex == contentViewControllers.count - 1)
        contentViewControllers[lastViewedIndex].updateProgressBar(progress: 0)

        setupTimer()
    }

    @objc private func timerAction() {
        elapsedTime += 1.0
        if elapsedTime >= progressBarMaxValue {
            if currentIndex < contentViewControllers.count - 1 {
                currentIndex += 1
                lastViewedIndex = currentIndex
                setViewControllers([contentViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
                resetTimerAndProgress()
            } else {
                contentViewControllers[currentIndex].updateProgressBar(progress: 1.0)
                loadNextPage()
            }
        } else {
            if currentIndex < contentViewControllers.count {
                contentViewControllers[currentIndex].updateProgressBar(progress: elapsedTime / progressBarMaxValue)
            }
        }
    }

    private func loadNextPage() {
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true

        let fetchNextPage = Observable.just(())
        let input = FeedPageViewModel.Input(trigger: Observable.never(), fetchNextPage: fetchNextPage)
        let output = viewModel.transform(input: input)

        output.posts
            .asObservable()
            .subscribe(onNext: { [weak self] newPosts in
                guard let self = self else { return }
                self.addNewViewControllers(newPosts: newPosts)
                self.isLoadingNextPage = false
            }, onError: { [weak self] error in
                self?.isLoadingNextPage = false
                print("Error loading next page: \(error.localizedDescription)")
            }, onCompleted: { [weak self] in
                self?.isLoadingNextPage = false
            })
            .disposed(by: disposeBag)
    }
    
    private func preloadNextPagesIfNeeded(currentIndex: Int) {
        // 현재 인덱스가 3의 배수일 때와 다음 페이지가 로딩 중이 아닐 때에만 사전 로드를 수행
        guard (currentIndex + 1) % 3 == 0, !isLoadingNextPage else { return }
        isLoadingNextPage = true

        let fetchNextPage = Observable.just(())
        let input = FeedPageViewModel.Input(trigger: Observable.never(), fetchNextPage: fetchNextPage)
        let output = viewModel.transform(input: input)

        output.posts
            .asObservable()
            .subscribe(onNext: { [weak self] newPosts in
                guard let self = self else { return }
                // 새로운 게시물 데이터를 추가
                self.addNewViewControllers(newPosts: newPosts)
                self.isLoadingNextPage = false
            }, onError: { [weak self] error in
                // 오류 발생 시 로딩 상태 해제
                self?.isLoadingNextPage = false
            }, onCompleted: { [weak self] in
                // 작업 완료 시 로딩 상태 해제
                self?.isLoadingNextPage = false
            })
            .disposed(by: disposeBag)
    }


    private func addNewViewControllers(newPosts: [Post]) {
        let newViewControllers = newPosts.map { post -> FeedContentViewController in
            let vc = FeedContentViewController()
            vc.loadPost(post: post)
            vc.viewModel.postDeleteSuccess
                .subscribe(onNext: { [weak self] _ in
                    self?.moveToNextPage()
                })
                .disposed(by: vc.disposeBag)
            return vc
        }

        contentViewControllers.append(contentsOf: newViewControllers)
    }
    
    private func resetTimer() {
        invalidateTimer()
        elapsedTime = 0
        guard currentIndex < contentViewControllers.count else { return }
        contentViewControllers[currentIndex].updateProgressBar(progress: 0)
        setupTimer()
    }
    
    private func updateProgressBarForCurrentPage() {
        guard currentIndex < contentViewControllers.count else { return }
        contentViewControllers[currentIndex].updateProgressBar(progress: 0)
    }
}

extension FeedPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = contentViewControllers.firstIndex(of: viewController as! FeedContentViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        
        return contentViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = contentViewControllers.firstIndex(of: viewController as! FeedContentViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        if nextIndex < contentViewControllers.count {
            return contentViewControllers[nextIndex]
        } else {
            loadNextPage()
            return nil
        }
    }
}

extension FeedPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let viewController = pageViewController.viewControllers?.first as? FeedContentViewController {
                if let index = contentViewControllers.firstIndex(of: viewController) {
                    currentIndex = index
                    lastViewedIndex = index
                    resetTimerAndProgress()
                    preloadNextPagesIfNeeded(currentIndex: currentIndex)
                }
            }
    }
}
