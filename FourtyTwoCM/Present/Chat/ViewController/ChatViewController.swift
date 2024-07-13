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
import RealmSwift

final class ChatViewController: BaseViewController {
    
    var viewModel: ChatViewModel!
    
    let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    let chatRepository = ChatRepository()
    
    private lazy var chatMessageTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.allowsSelection = false
        $0.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
    }
    
    private let messageTextFieldBackgroundView = UIView().then {
        $0.backgroundColor = .backgroundBlack.withAlphaComponent(0.5)
    }
    
    private let messageTextField = PaddedTextField().then {
        $0.placeholder = "메시지를 입력하세요..."
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .superDarkGray
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.unactiveGray.cgColor
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        
        let realm = try! Realm()
        print("realm url: \(String(describing: realm.configuration.fileURL))")
    }
    
    override func bind() {
        let input = ChatViewModel.Input(
            loadMessage: self.rx.viewWillAppear.map { _ in }
        )
        
        let output = viewModel.transform(input: input)
        
        output.messages
            .drive(chatMessageTableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { row, message, cell in
                let isOutgoing = message.sender?.userId ?? "" == self.userId
                let isFirst = row == 0
                cell.configure(with: message, isOutgoing: isOutgoing, isFirst: isFirst)
            }
            .disposed(by: disposeBag)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            chatMessageTableView,
            messageTextFieldBackgroundView,
            messageTextField
        ])
    }
    
    override func configLayout() {
        chatMessageTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        messageTextFieldBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        messageTextField.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.leading.trailing.equalTo(messageTextFieldBackgroundView).inset(16)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-8)
        }
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        messageTextField.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
