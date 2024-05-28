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
    private let progressBarMaxValue: Float = 7.0 // 7초. 프로그레스 바의 최대 값
    private var elapsedTime: Float = 0.0 // 경과 시간
    private var isLastPageReached = false // 마지막 페이지에 도달했는지
    private var isLoadingNextPage = false // 다음 페이지 로드 중인지

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        bind()
        setupTimer()
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
    }
}

extension FeedPageViewController {
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
    
    private func resetTimerAndProgress() {
        timer?.invalidate()  // 기존 타이머 중지
        elapsedTime = 0      // 경과 시간 리셋

        guard currentIndex < contentViewControllers.count else { return } // Index 범위 초과를 방지
        
        isLastPageReached = (currentIndex == contentViewControllers.count - 1) // 마지막 페이지 여부 설정
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        updateProgressBarForCurrentPage()  // 프로그레스 바 업데이트
    }

    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc private func timerAction() {
        elapsedTime += 1.0
        if elapsedTime >= progressBarMaxValue {
            if currentIndex < contentViewControllers.count - 1 {
                currentIndex += 1
                setViewControllers([contentViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
                resetTimerAndProgress() // 새 페이지로 전환 시 프로그레스 바와 타이머 재설정
            } else {
                timer?.invalidate()
                contentViewControllers[currentIndex].updateProgressBar(progress: 1.0) // 마지막 페이지에서는 프로그레스 바를 꽉 채우고 멈춤
                loadNextPage() // 페이지의 마지막 게시글에 도달하면 다음 페이지 로드
            }
        } else {
            if currentIndex < contentViewControllers.count {
                contentViewControllers[currentIndex].updateProgressBar(progress: elapsedTime / progressBarMaxValue)
            }
        }
    }

    private func moveToNextPage() {
        if currentIndex >= contentViewControllers.count - 1 {
            loadNextPage() // 마지막 페이지에서 다음 페이지 로드
            return
        }

        currentIndex += 1
        let nextViewController = contentViewControllers[currentIndex]
        setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] completed in
            if completed {
                self?.resetTimerAndProgress() // 페이지 전환 완료 후 타이머 리셋
            }
        }
    }

    private func loadNextPage() {
        guard !isLoadingNextPage else {
            print("다음 페이지를 로드 중입니다.")
            return
        }

        isLoadingNextPage = true // 다음 페이지 로드 중으로 설정

        let fetchNextPage = Observable.just(())
        let input = FeedPageViewModel.Input(trigger: Observable.never(), fetchNextPage: fetchNextPage)
        let output = viewModel.transform(input: input)

        output.posts
            .asObservable()
            .subscribe(onNext: { [weak self] newPosts in
                guard let self = self else { return }
                self.addNewViewControllers(newPosts: newPosts)
                self.isLoadingNextPage = false // 로드 완료 후 플래그 해제
            }, onError: { [weak self] (error: Error) in
                self?.isLoadingNextPage = false // 에러 발생 시 플래그 해제
                print("Error loading next page: \(error.localizedDescription)")
            }, onCompleted: { [weak self] in
                self?.isLoadingNextPage = false // 완료 시 플래그 해제
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

        let previousCount = contentViewControllers.count
        contentViewControllers.append(contentsOf: newViewControllers)

        // 새 게시글이 추가된 경우 타이머를 재설정하고 다음 페이지로 이동
        if previousCount == contentViewControllers.count - newViewControllers.count && !newViewControllers.isEmpty {
            currentIndex = previousCount // 추가된 첫 게시글로 인덱스 설정
            setViewControllers([contentViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
            resetTimerAndProgress()
        }
    }

    
    private func resetTimer() {
        timer?.invalidate() // 기존 타이머를 중지
        elapsedTime = 0 // 경과 시간을 0으로 리셋
        guard currentIndex < contentViewControllers.count else { return } // Index 범위 초과를 방지
        contentViewControllers[currentIndex].updateProgressBar(progress: 0) // 프로그레스 바를 초기화
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    private func updateProgressBarForCurrentPage() {
        guard currentIndex < contentViewControllers.count else { return } // Index 범위 초과를 방지
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
        guard nextIndex < contentViewControllers.count else {
            return nil
        }
        
        return contentViewControllers[nextIndex]
    }
}

extension FeedPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let viewController = pageViewController.viewControllers?.first as? FeedContentViewController {
            if let index = contentViewControllers.firstIndex(of: viewController) {
                currentIndex = index
                resetTimerAndProgress()

                // 마지막 페이지에서 다음 페이지를 로드
                if currentIndex == contentViewControllers.count - 1 {
                    loadNextPage()
                }
            }
        }
    }
}
