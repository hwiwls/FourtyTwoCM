//
//  SignUpViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import SnapKit
import Then
import Toast

final class SignInViewController: BaseViewController {
    
    private let viewModel = SignInViewModel()
    
    private let logoLabel = UILabel().then {
        $0.text = "fourty-two\ncentimeters"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .offWhite
        $0.font = .aggro.aggroMedium32
    }
    
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요").then {
        $0.keyboardType = .emailAddress
        $0.autocorrectionType = .no // 자동완성 구역 없애기
        $0.textContentType = .oneTimeCode   // 텍스트 필드가 일회용 코드 입력을 위한 것임을 나타냄
    }
    
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요").then {
        $0.isSecureTextEntry = true
        $0.keyboardType = .default
        $0.textContentType = .oneTimeCode   // 텍스트 필드가 일회용 코드 입력을 위한 것임을 나타냄
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
    
    override func bind() {
        let input = SignInViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            loginButtonTapped: signInButton.rx.tap.asObservable(), 
            signUpButtonTapped: signUpButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.loginValidation
            .drive(with: self) { owner, value in
                owner.signInButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        
        output.loginSuccessTrigger
            .drive(with: self) { owner, _ in
                let vc = TabBarController()
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                
                UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    sceneDelegate.window?.rootViewController = vc
                })
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(with: self) { owner, message in
                owner.view.makeToast(message, duration: 3.0, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.signUpTrigger
            .drive(with: self) { owner, _ in
                let signUpVC = SignUpViewController()
                owner.navigationController?.pushViewController(signUpVC, animated: true)
            }
            .disposed(by: disposeBag)
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
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

}
