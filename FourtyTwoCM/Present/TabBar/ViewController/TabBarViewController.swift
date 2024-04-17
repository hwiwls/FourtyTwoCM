//
//  TabBarViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/15/24.
//


import UIKit
import SnapKit
import Then

final class TabBarController: UITabBarController {
    
    private let topBorder = UIView().then {
        $0.backgroundColor = .tabBarBorderGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarConfig()
        
        do {
            let accessToken = try Keychain.shared.getToken(kind: .accessToken)
            print("Access Token을 겟또: \(accessToken)")
        } catch {
            print("Error retrieving access token: \(error)")
        }
        
        do {
            let refreshToken = try Keychain.shared.getToken(kind: .refreshToken)
            print("Refresh Token을 겟또: \(refreshToken)")
        } catch {
            print("Error retrieving refresh token: \(error)")
        }
    }
    
    private func tabBarConfig() {
        tabBar.barTintColor = .black
        tabBar.backgroundColor = .black
        tabBar.tintColor = .offWhite
        tabBar.isTranslucent = false
        
        tabBar.addSubview(topBorder)
        
        topBorder.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        let feedViewController = UINavigationController(
            rootViewController: FeedViewController()
        )
        
        let searchViewController = UINavigationController(
            rootViewController: SearchViewController()
        )
        
        let addPostViewController = UINavigationController(
            rootViewController: AddPostViewController()
        )
        
        let likeViewController = UINavigationController(
            rootViewController: LikeViewController()
        )
        
        let myPageViewController = UINavigationController(
            rootViewController: MyPageViewController()
        )
        
        feedViewController.tabBarItem = UITabBarItem(
            title: "둘러보기",
            image: UIImage(named: "home")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.unactiveGray),
            selectedImage: UIImage(named: "home")
        )
        
        
        searchViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "magnifyingglass")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.unactiveGray),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        addPostViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "plus.app")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.unactiveGray),
            selectedImage: UIImage(systemName: "plus.app")
        )
        
        likeViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "heart")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.unactiveGray),
            selectedImage: UIImage(systemName: "heart")
        )
        
        myPageViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.unactiveGray),
            selectedImage: UIImage(systemName: "person")
        )
        
        let tabItems = [
            feedViewController,
            searchViewController,
            addPostViewController,
            likeViewController,
            myPageViewController
        ]
        
        setViewControllers(tabItems, animated: true)
        
    }

    
    
}

