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
import Toast

final class CommentViewController: BaseViewController {
    
    var viewModel = CommentViewModel(postId: "")
    
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
 
    override func bind() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        let input = CommentViewModel.Input(
            closeTrigger: closeButton.rx.tap.asObservable(),
            textInput: commentTextField.rx.text.orEmpty.asObservable(),
            keyboardDismissalTrigger: tapGesture.rx.event.map { _ in }.asObservable(),
            submitCommentTrigger: submitButton.rx.tap.asObservable(),
            commentText: commentTextField.rx.text.orEmpty.asObservable()
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
        
        
        comments.asObservable()
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
        
        output.refreshComments
            .drive(onNext: { [weak self] newComments in
                print("Updating comments table with: \(newComments)")
                self?.comments.onNext(newComments)
                self?.commentTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.commentSubmitted
            .drive(onNext: { [weak self] newComment in
                guard let self = self else { return }
                
                var currentComments = (try? self.comments.value()) ?? []
                currentComments.append(newComment)
                self.comments.onNext(currentComments)
                self.commentTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        output.errors
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }

    
    private func showError(_ error: Error) {
        if let apiError = error as? APIError {
            self.view.makeToast(apiError.errorMessage, duration: 2.0, position: .top)
        } else {
            self.view.makeToast("알 수 없는 오류가 발생했습니다: \(error)", duration: 2.0, position: .top)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
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
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.width.height.equalTo(30)
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(commentTextField.snp.top).offset(-12)
        }
        
        commentTextField.snp.makeConstraints {
            textFieldBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20).constraint
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(44)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: 키보드 관련 처리
extension CommentViewController {
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
}
