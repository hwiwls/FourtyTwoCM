//
//  TabBarViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/15/24.
//

import UIKit
import SnapKit
import PhotosUI

final class TabBarController: UITabBarController, PHPickerViewControllerDelegate {
    
    private let customTabBar = CustomTabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarConfig()
        view.backgroundColor = .backgroundBlack
    }
    
    private func tabBarConfig() {
        setValue(customTabBar, forKey: "tabBar")
        
        tabBar.barTintColor = .black
        tabBar.backgroundColor = .black
        tabBar.tintColor = .offWhite
        tabBar.isTranslucent = false
        
        let feedViewController = UINavigationController(rootViewController: FeedPageViewController())
        let myPageViewController = UINavigationController(rootViewController: MyPageViewController())
        let postMapViewController = UINavigationController(rootViewController: PostMapViewController())
        let chattingViewController = UINavigationController(rootViewController: ChatRoomListViewController())

        let connectActive = resizeImage(image: UIImage(named: "connect_active")!, targetSize: CGSize(width: 32, height: 32))
        let connectUnactive = resizeImage(image: UIImage(named: "connect_unactive")!, targetSize: CGSize(width: 32, height: 32))
        
        let compassActive = resizeImage(image: UIImage(named: "compass_active")!, targetSize: CGSize(width: 32, height: 32))
        let compassUnactive = resizeImage(image: UIImage(named: "compass_unactive")!, targetSize: CGSize(width: 32, height: 32))
        
        let circleActive = resizeImage(image: UIImage(named: "circle_active")!, targetSize: CGSize(width: 32, height: 32))
        let circleUnactive = resizeImage(image: UIImage(named: "circle_unactive")!, targetSize: CGSize(width: 32, height: 32))
        
        let personActive = resizeImage(image: UIImage(named: "person_active")!, targetSize: CGSize(width: 32, height: 32))
        let personUnactive = resizeImage(image: UIImage(named: "person_unactive")!, targetSize: CGSize(width: 32, height: 32))
        
        feedViewController.tabBarItem = UITabBarItem(title: "가까워지기", image: connectUnactive, selectedImage: connectActive)
        myPageViewController.tabBarItem = UITabBarItem(title: "마이페이지", image: personUnactive, selectedImage: personActive)
        postMapViewController.tabBarItem = UITabBarItem(title: "둘러보기", image: compassUnactive, selectedImage: compassActive)
        chattingViewController.tabBarItem = UITabBarItem(title: "대화하기", image: circleUnactive, selectedImage: circleActive)

        let tabItems = [feedViewController, postMapViewController, UIViewController(), chattingViewController, myPageViewController]
        setViewControllers(tabItems, animated: true)
        
        tabBar.items?[2].isEnabled = false
        
        customTabBar.middleButton.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)
    }
    
    @objc private func middleButtonAction() {
        presentImagePicker()
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.navigateToPostCreation(image: image)
                    }
                }
            }
        }
    }

    private func navigateToPostCreation(image: UIImage) {
        let postCreationVC = PostCreationViewController()
        postCreationVC.viewModel = PostCreationViewModel(image: image)
        postCreationVC.modalPresentationStyle = .fullScreen
        present(postCreationVC, animated: true)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
