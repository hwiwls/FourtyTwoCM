//
//  LikesViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import UIKit

class MyLikesViewController: UIViewController {
    private let viewModel = MyLikesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("likesviewcontroller loaded")
        
        bindViewModel()
        view.backgroundColor = .blue
    }
    
   

    

    private func bindViewModel() {
        // Binding logic with RxSwift
    }
}
