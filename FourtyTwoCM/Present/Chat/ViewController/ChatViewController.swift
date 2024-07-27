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
    
    enum EntryType {
        case feedContent
        case chatList
    }
    
    var entryType: EntryType = .chatList
    var viewModel: ChatViewModel!
    
    let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    let chatRepository = ChatRepository(userId: UserDefaults.standard.string(forKey: "userID") ?? "")
    
    private lazy var chatMessageTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.allowsSelection = false
        $0.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 60, right: 0)
    }
    
    private let messageTextFieldBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private let messageTextField = PaddedTextField().then {
        $0.placeholder = "메시지를 입력하세요..."
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .superDarkGray
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.unactiveGray.cgColor
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 68)
    }
    
    private let sendMessageBtn = SubmitButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
    }
    
    override func bind() {
        guard let viewModel = viewModel else {
            fatalError("viewModel is not initialized")
        }
        
        let input = ChatViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.map { _ in },
            viewWillDisappear: self.rx.viewWillDisappear.map { _ in },
            messageSent: sendMessageBtn.rx.tap
                            .withLatestFrom(messageTextField.rx.text.orEmpty)
                            .filter { !$0.isEmpty }
                            .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.messages
            .drive(chatMessageTableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { row, message, cell in
                let isOutgoing = (message.sender?.userId ?? "") == self.userId
                cell.configure(with: message, isOutgoing: isOutgoing)
            }
            .disposed(by: disposeBag)
        
        output.messageSentSuccess
            .emit(onNext: { [weak self] in
                self?.messageTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] errorMessage in
                self?.view.makeToast(errorMessage, duration: 2.0, position: .center)
            })
            .disposed(by: disposeBag)
        
        self.rx.viewWillDisappear
            .subscribe(onNext: { [weak self] _ in
                if let tabBarController = self?.tabBarController {
                    // 현재 선택된 탭이 '채팅'이 아닐 때만 타이머를 리셋하도록 알림
                    if tabBarController.selectedIndex != 3 { 
                        NotificationCenter.default.post(name: .didDismissModalViewController, object: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            chatMessageTableView,
            messageTextFieldBackgroundView,
            messageTextField,
            sendMessageBtn
        ])
    }
    
    override func configLayout() {
        chatMessageTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        messageTextFieldBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(messageTextField.snp.top).offset(-4)
            $0.bottom.equalToSuperview()
        }
        
        messageTextField.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.leading.trailing.equalTo(messageTextFieldBackgroundView).inset(16)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-8)
        }
        
        sendMessageBtn.snp.makeConstraints {
            $0.trailing.equalTo(messageTextField).inset(8)
            $0.top.bottom.equalTo(messageTextField).inset(4)
            $0.width.equalTo(52)
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
        switch entryType {
        case .feedContent:
            dismiss(animated: true, completion: nil)
        case .chatList:
            navigationController?.popViewController(animated: true)
        }
    }
}
