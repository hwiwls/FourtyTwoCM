//
//  File.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import UIKit

final class MyPostsViewController: UIViewController {
    
    private let viewModel = MyPostsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupCollectionView()
        bindViewModel()
        view.backgroundColor = .green
    }

   

    private func bindViewModel() {
        // Binding logic with RxSwift
    }
}
