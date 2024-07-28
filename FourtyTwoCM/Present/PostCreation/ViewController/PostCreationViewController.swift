//
//  PostCreationViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Toast

final class PostCreationViewController: BaseViewController {
    var viewModel: PostCreationViewModel!

    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .offWhite
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    private let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let contentTitleImageView = UIImageView().then {
        $0.image = UIImage(named: "writelogo")
    }
    
    private let contentTitleLabel = UILabel().then {
        $0.text = "내용"
        $0.textColor = .offWhite
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .left
    }
    
    
    private let postTextView = UITextView().then {
        $0.backgroundColor = .clear
        $0.font = .systemFont(ofSize: 15)
        $0.text = "내용, 해시태그를 입력해주세요"
    }
    
    private let uploadBtn = PointButton(title: "Upload")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("post creation view controller loaded")
        setupToolbar()
    }
    
    override func bind() {
        let input = PostCreationViewModel.Input(
            submitTap: uploadBtn.rx.tap.asObservable(),
            textChanged: postTextView.rx.text.orEmpty.asObservable(),
            editingBegan: postTextView.rx.didBeginEditing.asObservable(),
            editingEnded: postTextView.rx.didEndEditing.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.postText
            .drive(postTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.textColor
            .drive(onNext: { [weak self] color in
                self?.postTextView.textColor = color
            })
            .disposed(by: disposeBag)
        
        output.image
            .drive(postImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.postSubmitted
            .drive(onNext: { [weak self] _ in
                self?.dismissAndSwitchToMyPage()
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .drive(onNext: { [weak self] message in
                self?.view.makeToast(message, duration: 2.0, position: .top)
            })
            .disposed(by: disposeBag)
        
        postTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                    self.postTextView.text = "내용, 해시태그를 입력해주세요"
                    self.postTextView.textColor = .tabBarBorderGray
                
            })
            .disposed(by: disposeBag)
    }
    
    override func configView() {
        postTextView.textColor = .tabBarBorderGray
    }
            
    
    private func dismissAndSwitchToMyPage() {
        dismiss(animated: true) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let tabBarController = windowScene.windows.first?.rootViewController as? TabBarController else {
                return
            }
            tabBarController.selectedIndex = 4
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        
        postTextView.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            closeButton,
            postImageView,
            contentTitleImageView,
            contentTitleLabel,
            postTextView,
            uploadBtn
        ])
    }
    
    override func configLayout() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.size.equalTo(44)
        }
        
        postImageView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(170)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(52)
            $0.centerX.equalToSuperview()
        }
        
        contentTitleImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(postImageView.snp.bottom).offset(32)
        }
        
        contentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentTitleImageView.snp.top)
            $0.height.equalTo(20)
            $0.leading.equalTo(contentTitleImageView.snp.trailing).offset(8)
        }
        
        postTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.top.equalTo(contentTitleImageView.snp.bottom).offset(8)
            $0.height.equalTo(160)
        }
        
        uploadBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
        
    }
    
}
