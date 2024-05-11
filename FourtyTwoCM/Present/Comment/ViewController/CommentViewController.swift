//
//  CommentViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CommentViewController: BaseViewController {
    
    private let viewModel = CommentViewModel()
    
    var comments = BehaviorSubject<[Comment]>(value: [])
    
    private var textFieldBottomConstraint: Constraint?
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
        $0.imageView?.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 12
    }
 
    private lazy var commentTextField = PaddedTextField().then {
        $0.placeholder = "댓글 작성하기"
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.placeHolderGray.cgColor
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.textInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 72)
    }
    
    private lazy var submitButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysOriginal).withTintColor(.black), for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .offWhite
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
    }
    
    private lazy var commentTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentTableViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .superDarkGray
        setupViews()
        setupKeyboardNotifications()
        initialVisibilityCheck()
    }
 
    
    private func initialVisibilityCheck() {
        submitButton.isHidden = commentTextField.text?.isEmpty ?? true
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom
        textFieldBottomConstraint?.update(inset: keyboardHeight + 20)
        view.layoutIfNeeded()
    }

    @objc private func keyboardWillHide(notification: Notification) {
        textFieldBottomConstraint?.update(inset: 20)
        view.layoutIfNeeded()
    }
    
    private func setupViews() {
        commentTextField.rightView = submitButton
        commentTextField.rightViewMode = .always

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func configHierarchy() {
        view.addSubviews([
            closeButton,
            commentTextField,
            commentTableView
        ])
    }
    
    override func configLayout() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-10)
            $0.width.height.equalTo(30)
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(12)
            $0.bottom.equalTo(commentTextField.snp.top).offset(-12)
            $0.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        commentTextField.snp.makeConstraints {
            textFieldBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20).constraint
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(44)
        }
    }
    
    override func bind() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        let input = CommentViewModel.Input(
            closeTrigger: closeButton.rx.tap.asObservable(),
            textInput: commentTextField.rx.text.orEmpty.asObservable(),
            keyboardDismissalTrigger: tapGesture.rx.event.map { _ in }.asObservable()
        )
            
        let output = viewModel.transform(input: input)
            
        output.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        output.submitButtonVisible
            .drive(onNext: { [weak self] isVisible in
                self?.commentTextField.rightView?.isHidden = !isVisible
            })
            .disposed(by: disposeBag)
        
        submitButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.commentTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        comments.asObservable()
            .map { $0.reversed() }
            .bind(to: commentTableView.rx.items(cellIdentifier: "CommentTableViewCell", cellType: CommentTableViewCell.self)) { _, comment, cell in
                cell.configure(with: comment)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        
        output.keyboardDismiss
                    .drive(onNext: { [weak self] _ in
                        self?.view.endEditing(true)
                    })
                    .disposed(by: disposeBag)
    }

}
