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

    private var contentViewControllers: [UIViewController] = []
    private let viewModel = FeedPageViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        // 예시 데이터 - 실제 구현에서는 ViewModel을 통해 데이터를 받아야 함
        let items = ["SampleImg1", "SampleImg2", "SampleImg3"]
        self.contentViewControllers = items.map { imageName in
            let vc = FeedContentViewController()
            vc.updateImage(imageName: imageName)
            return vc
        }
        
        if let firstViewController = contentViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
}

extension FeedPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = contentViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        
        return contentViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = contentViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < contentViewControllers.count else {
            return nil
        }
        
        return contentViewControllers[nextIndex]
    }
}

