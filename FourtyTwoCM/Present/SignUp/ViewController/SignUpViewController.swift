//
//  SignUpViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/20/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController {
    
    private let viewModel = SignUpViewModel()
    
    private let emailLabel = UILabel().then {
        $0.text = "이메일을 입력해주세요"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .offWhite
        $0.textAlignment = .left
    }

    private let emailTextField = SignTextField(placeholderText: "이메일").then {
        $0.keyboardType = .emailAddress
        $0.autocorrectionType = .no
    }
    
    private let emailValidLabel = UILabel().then {
        $0.text = "이메일이 올바르지 않습니다"
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .offWhite
        $0.textAlignment = .left
        $0.isHidden = true
    }
    
    private let emailValidationBtn = UIButton().then {
        $0.backgroundColor = .offWhite
        $0.setTitle("중복확인", for: .normal)
        $0.setTitleColor(.backgroundBlack, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 13)
        $0.layer.cornerRadius = 20
    }
    
    private let passwordLabel = UILabel().then {
        $0.text = "비밀번호를 입력해주세요"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .offWhite
        $0.textAlignment = .left
    }
    
    private let passwordTextField = SignTextField(placeholderText: "비밀번호").then {
        $0.isSecureTextEntry = true
        $0.keyboardType = .default
        $0.textContentType = .oneTimeCode 
    }
    
    private let passwordValidLabel = UILabel().then {
        $0.text = "8자~20자 이내로 입력해주세요"
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .offWhite
        $0.textAlignment = .left
        $0.isHidden = true
    }
    
    let signUpButton = PointButton(title: "Join")
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func bind() {
        let input = SignUpViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            signUpButtonTapped: signUpButton.rx.tap.asObservable(),
            emailValidationButtonTapped: signUpButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
    }
    
    override func configNav() {
        self.navigationItem.title = "회원가입"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.offWhite]
        
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.offWhite)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            emailLabel,
            emailTextField,
            emailValidLabel,
            emailValidationBtn,
            passwordLabel,
            passwordTextField,
            passwordValidLabel,
            signUpButton
        ])
    }
    
    override func configLayout() {
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.trailing.equalTo(emailValidationBtn.snp.leading).offset(-8)
            $0.height.equalTo(40)
        }
        
        emailValidLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        emailValidationBtn.snp.makeConstraints {
            $0.top.bottom.equalTo(emailTextField)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.width.equalToSuperview().multipliedBy(0.15)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(emailValidLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(40)
        }
        
        passwordValidLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(passwordValidLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(45)
        }
        
    }
    

}
