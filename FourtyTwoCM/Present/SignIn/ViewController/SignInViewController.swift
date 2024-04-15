//
//  SignUpViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import SnapKit
import Then

final class SignInViewController: BaseViewController {
    
    private let logoLabel = UILabel().then {
        $0.text = "fourty-two\ncentimeters"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .offWhite
        $0.font = .aggro.aggroMedium32
    }
    
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요").then {
        $0.keyboardType = .emailAddress
    }
    
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요").then {
        $0.isSecureTextEntry = true
        $0.keyboardType = .default
    }
    
    private let signInButton = PointButton(title: "LogIn")
    
    private let signUpButton = UIButton().then {
        $0.setTitle("아이디가 없으신가요? 회원가입하기", for: .normal)
        $0.setTitleColor(.offWhite, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
    }
    
    override func configHierarchy() {
        view.addSubviews([
            logoLabel,
            emailTextField,
            passwordTextField,
            signInButton,
            signUpButton
        ])
    }
    
    override func configLayout() {
        logoLabel.snp.makeConstraints {
            $0.bottom.equalTo(emailTextField.snp.top).offset(-50)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        emailTextField.snp.makeConstraints {
            $0.bottom.equalTo(passwordTextField.snp.top).offset(-12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(40)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(12)
            $0.trailing.equalTo(passwordTextField)
            $0.height.equalTo(20)
        }
        
        signInButton.snp.makeConstraints {
            $0.top.equalTo(signUpButton.snp.bottom).offset(44)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(44)
        }
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: 100, height: 44)
            )
        )
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

}
