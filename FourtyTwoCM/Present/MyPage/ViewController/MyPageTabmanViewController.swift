//
//  MyPageTabmanViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import UIKit
import SnapKit
import Tabman
import Pageboy

final class MyPageTabmanViewController: TabmanViewController {
    
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        self.dataSource = self
        
        let bar = TMBar.ButtonBar()
        configureTabBar(bar: bar)
        addBar(bar, dataSource: self, at: .top)
    }
    
    private func setupViewControllers() {
        let firstVC = MyPostsViewController()
        let secondVC = MyLikesViewController()
        
        viewControllers = [firstVC, secondVC]
    }
    
    private func configureTabBar(bar: TMBar.ButtonBar) {
        bar.layout.transitionStyle = .snap
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        bar.layout.contentMode = .fit
        bar.layout.interButtonSpacing = 20
        
        bar.backgroundView.style = .clear

        bar.buttons.customize { (button) in
            button.tintColor = .white
            button.selectedTintColor = .white
            button.font = UIFont.systemFont(ofSize: 17)
            button.selectedFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }

        bar.indicator.weight = .custom(value: 3)
        bar.indicator.tintColor = .white
    }
}

extension MyPageTabmanViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "활동")
        case 1:
            return TMBarItem(title: "좋아요")
        default:
            return TMBarItem(title: "Page \(index)")
        }
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        guard index < viewControllers.count else { return nil }
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 0)
    }
}
