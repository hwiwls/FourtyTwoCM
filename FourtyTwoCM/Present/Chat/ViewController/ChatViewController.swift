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

struct DummyMessage {
    let senderID: String
    let text: String
}

final class ChatViewController: BaseViewController {
    
    var viewModel: ChatViewModel!
    
    let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    private lazy var chatMessageTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.allowsSelection = false
        $0.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = ChatViewModel.Input(
            loadMessage: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        output.messages
            .drive(chatMessageTableView.rx.items(cellIdentifier: "ChatMessageCell", cellType: ChatMessageCell.self)) { row, message, cell in
                let isOutgoing = message.senderID == self.userId
                let isFirst = row == 0 
                cell.configure(with: message, isOutgoing: isOutgoing, isFirst: isFirst)
            }
            .disposed(by: disposeBag)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            chatMessageTableView
        ])
    }
    
    override func configLayout() {
        chatMessageTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
