//
//  ChattingViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatRoomListViewController: BaseViewController {
    
    private lazy var chatRoomListTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(GenericTableViewCell.self, forCellReuseIdentifier: "GenericTableViewCell")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        
    }
    
    override func configHierarchy() {
        view.addSubview(chatRoomListTableView)
    }
    
    override func configLayout() {
        chatRoomListTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
