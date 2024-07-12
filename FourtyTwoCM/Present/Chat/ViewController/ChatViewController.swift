//
//  ChatViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChatViewController: BaseViewController {
    
    var viewModel: ChatViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func bind() {
        
        
    }
    
    override func configHierarchy() {
        
    }
    
    override func configLayout() {
        
    }
    
    override func configNav() {
        let titleLabel = UILabel()
        titleLabel.text = viewModel.participantNick
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .offWhite
        titleLabel.sizeToFit()
        
        let titleItem = UIBarButtonItem(customView: titleLabel)

        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.offWhite)
        let backItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))

        navigationItem.leftBarButtonItems = [backItem, titleItem]
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.offWhite]
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}
