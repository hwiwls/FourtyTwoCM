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
    
    private let topBorder = UIView().then {
        $0.backgroundColor = .tabBarBorderGray
    }
    
    private let middleButton = UIButton().then {
        $0.backgroundColor = .offWhite
        $0.layer.cornerRadius = 26
        $0.setImage(UIImage(systemName: "plus")?.withTintColor(UIColor.customColor.backgroundBlack, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarConfig()
        setupMiddleButton()
        view.backgroundColor = .backgroundBlack
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
        
        let feedViewController = UINavigationController(rootViewController: FeedPageViewController())
        let myPageViewController = UINavigationController(rootViewController: MyPageViewController())

        
        let connectActive = resizeImage(image: UIImage(named: "connect_active")!, targetSize: CGSize(width: 32, height: 32))
        
        let connectUnactive = resizeImage(image: UIImage(named: "connect_unactive")!, targetSize: CGSize(width: 32, height: 32))
        
        let personActive = resizeImage(image: UIImage(named: "person_active")!, targetSize: CGSize(width: 32, height: 32))
        
        let personUnactive = resizeImage(image: UIImage(named: "person_unactive")!, targetSize: CGSize(width: 32, height: 32))
        
        feedViewController.tabBarItem = UITabBarItem(title: "가까워지기", image: connectUnactive, selectedImage: connectActive)
        myPageViewController.tabBarItem = UITabBarItem(title: "마이페이지", image: personUnactive, selectedImage: personActive)

        let tabItems = [feedViewController, UIViewController(), myPageViewController]
        setViewControllers(tabItems, animated: true)
        
        tabBar.items?[1].isEnabled = false
    }
    
    private func setupMiddleButton() {
        middleButton.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)
        view.addSubview(middleButton)
        
        middleButton.snp.makeConstraints {
            $0.centerX.equalTo(tabBar.snp.centerX)
            $0.top.equalTo(tabBar.snp.top).offset(-20)
            $0.width.height.equalTo(52)
        }
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
            
            // 새 이미지 크기 결정
            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }

            // 이미지 렌더링
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
}
