//
//  FeedViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa

final class FeedPageViewController: UIPageViewController {

    private var contentViewControllers: [FeedContentViewController] = []
    private let viewModel = FeedPageViewModel()
    private let disposeBag = DisposeBag()
    
    private var currentIndex: Int = 0
    private var timer: Timer?
    private let progressBarMaxValue: Float = 7.0
    private var elapsedTime: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        bind()
        setupTimer()
    }
    
    private func bind() {
        let input = FeedPageViewModel.Input(trigger: .just(()))
        let output = viewModel.transform(input: input)

        output.posts
            .drive(onNext: { [weak self] posts in
                self?.setupViewControllers(posts: posts)
            })
            .disposed(by: disposeBag)
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
        contentViewControllers.remove(at: currentIndex) // 현재 페이지 삭제
        
        currentIndex = currentIndex % contentViewControllers.count // 새 인덱스 계산
        let nextViewController = contentViewControllers[currentIndex]
        setViewControllers([nextViewController], direction: .forward, animated: true) { [weak self] completed in
            if completed {
                self?.resetTimerAndProgress() // 페이지 전환 완료 후 타이머 리셋
            }
        }
    }

    private func resetTimerAndProgress() {
        timer?.invalidate()  // 기존 타이머 중지
        elapsedTime = 0      // 경과 시간 리셋
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        updateProgressBarForCurrentPage()  // 프로그레스 바 업데이트
    }


    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc private func timerAction() {
        elapsedTime += 1.0
        if elapsedTime >= progressBarMaxValue {
            if contentViewControllers.count > 1 {  // 페이지가 1개를 초과할 때만 다음 페이지로 이동
                currentIndex = (currentIndex + 1) % contentViewControllers.count
                setViewControllers([contentViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
            }
            resetTimerAndProgress()  // 새 페이지로 전환 시 프로그레스 바와 타이머 재설정
        } else {
            contentViewControllers[currentIndex].updateProgressBar(progress: elapsedTime / progressBarMaxValue)
        }
    }

    
    private func resetTimer() {
        timer?.invalidate() // 기존 타이머를 중지
        elapsedTime = 0 // 경과 시간을 0으로 리셋
        contentViewControllers[currentIndex].updateProgressBar(progress: 0) // 프로그레스 바를 초기화
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    private func updateProgressBarForCurrentPage() {
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
            }
        }
    }
}
