//
//  SignUpViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModelType {
    var disposeBag = DisposeBag()

    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let nicknameText: Observable<String>
        let signUpButtonTapped: Observable<Void>
        let emailValidationButtonTapped: Observable<Void>
    }

    struct Output {
        let emailValidationResult: Driver<String>
        let passwordValidationResult: Driver<String>
        let nicknameValidationResult: Driver<String>
        let signUpEnabled: Driver<Bool>
        let signUpSuccessTrigger: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let emailValid = BehaviorRelay(value: false)
        let passwordValid = BehaviorRelay(value: false)
        let nicknameValid = BehaviorRelay(value: false)
        let signUpSuccessTrigger = PublishRelay<Void>()

        input.emailValidationButtonTapped
            .withLatestFrom(input.emailText)
            .flatMapLatest { email in
                NetworkManager.performRequest(route: Router.emailValidation(query: EmailValidationQuery(email: email)), dataType: EmailValidationModel.self)
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                switch event {
                case .next(let validationModel):
                    if validationModel.message == "사용 가능한 이메일입니다." {
                        emailValid.accept(true)
                    } else {
                        emailValid.accept(false)
                    }
                case .error:
                    emailValid.accept(false)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        let emailValidationResult = emailValid
            .map { $0 ? "사용 가능한 이메일입니다." : "사용할 수 없는 이메일입니다." }
            .asDriver(onErrorJustReturn: "이메일 검증 오류 발생")

        let passwordValidationResult = input.passwordText
            .map { password in
                if password.count >= 5 && password.count <= 20 {
                    passwordValid.accept(true)
                    return "사용 가능한 비밀번호입니다."
                } else {
                    passwordValid.accept(false)
                    return "비밀번호는 5~20자로 구성되어야 합니다."
                }
            }
            .asDriver(onErrorJustReturn: "비밀번호 검증 오류 발생")

        let nicknameValidationResult = input.nicknameText
            .map { nickname in
                if nickname.count >= 3 && nickname.count <= 10 {
                    nicknameValid.accept(true)
                    return "사용 가능한 닉네임입니다."
                } else {
                    nicknameValid.accept(false)
                    return "닉네임은 3~10자로 구성되어야 합니다."
                }
            }
            .asDriver(onErrorJustReturn: "닉네임 검증 오류 발생")

        let signUpEnabled = Observable.combineLatest(emailValid, passwordValid, nicknameValid) { $0 && $1 && $2 }
            .asDriver(onErrorJustReturn: false)

        input.signUpButtonTapped
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText, input.nicknameText))
            .map { SignUpQuery(email: $0.0, password: $0.1, nick: $0.2) }
            .flatMapLatest { signUpQuery in
                NetworkManager.performRequest(route: Router.signUp(query: signUpQuery), dataType: SignUpModel.self)
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                switch event {
                case .next(_):
                    signUpSuccessTrigger.accept(())
                case .error(let error):
                    print("회원가입 오류: \(error)")
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        return Output(
            emailValidationResult: emailValidationResult,
            passwordValidationResult: passwordValidationResult,
            nicknameValidationResult: nicknameValidationResult,
            signUpEnabled: signUpEnabled,
            signUpSuccessTrigger: signUpSuccessTrigger.asDriver(onErrorJustReturn: ())
        )
    }
}
