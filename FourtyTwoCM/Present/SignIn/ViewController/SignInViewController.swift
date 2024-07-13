//
//  SignUpViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import SnapKit
//import Then
import Toast

final class SignInViewController: BaseViewController {
    
    private let viewModel = SignInViewModel()
    
    var sessionExpiredMessage: String?
    
    private let introduceLabel = UILabel().then {
        $0.text = "위치기반 실시간  커뮤니티 플랫폼"
        $0.textColor = .offWhite
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 13)
    }
    
    private let logoLabel = UILabel().then {
        $0.text = "fourty-two\ncentimeters"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .offWhite
        $0.font = .aggro.aggroMedium34
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let message = sessionExpiredMessage {
            showToast(message: message)
        }
    }

    func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
 
    override func bind() {
        let input = SignInViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            signInButtonTapped: signInButton.rx.tap.asObservable(),
            signUpButtonTapped: signUpButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isLoginButtonEnabled
            .drive(signInButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.signInSuccess
            .drive(with: self) { owner, _ in
                // 성공 시 처리 로직
                let isPermissioned = UserDefaults.standard.bool(forKey: "isPermissioned")
                if isPermissioned {
                    owner.transitionToMainInterface()
                } else {
                    owner.navigateToPermissionsInterface()
                }
            }
            .disposed(by: disposeBag)

        output.signInFailure
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

    private func transitionToMainInterface() {
        let tabBarVC = TabBarController()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarVC
        })
    }

    private func navigateToPermissionsInterface() {
        let permissionVC = PermissionsViewController()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let rootViewController = sceneDelegate.window?.rootViewController as? UINavigationController else {
            print("Navigation controller not found")
            return
        }
        DispatchQueue.main.async {
            rootViewController.pushViewController(permissionVC, animated: true)
        }
    }

    
    override func configHierarchy() {
        view.addSubviews([
            logoLabel,
            introduceLabel,
            emailTextField,
            passwordTextField,
            signInButton,
            signUpButton
        ])
    }
    
    override func configLayout() {
        logoLabel.snp.makeConstraints {
            $0.bottom.equalTo(emailTextField.snp.top).offset(-60)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        introduceLabel.snp.makeConstraints {
            $0.bottom.equalTo(logoLabel.snp.top).offset(-8)
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
