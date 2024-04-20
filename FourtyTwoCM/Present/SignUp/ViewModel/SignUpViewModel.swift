//
//  SignUpViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa
import Toast

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
        let emailValid = BehaviorSubject<Bool>(value: false)
        let passwordValid = BehaviorSubject<Bool>(value: false)
        let nicknameValid = BehaviorSubject<Bool>(value: false)
        let signUpSuccessTrigger = PublishRelay<Void>()

        input.emailValidationButtonTapped
            .withLatestFrom(input.emailText)
            .flatMapLatest { email in
                NetworkManager.requestEmailValid(query: EmailValidationQuery(email: email))
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                switch event {
                case .next(let validationModel):
                    if validationModel.message == "사용 가능한 이메일입니다." {
                        emailValid.onNext(true)
                    } else {
                        emailValid.onNext(false)
                    }
                case .error:
                    emailValid.onNext(false)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        let emailValidationResult = emailValid
            .map { $0 ? "사용할 수 있는 이메일입니다" : "사용할 수 없는 이메일입니다" }
            .asDriver(onErrorJustReturn: "사용할 수 없는 이메일입니다")

        let passwordValidationResult = input.passwordText
            .map { password in
                if password.count >= 5 && password.count <= 20 {
                    passwordValid.onNext(true)
                    return "사용할 수 있는 비밀번호입니다"
                } else {
                    passwordValid.onNext(false)
                    return "비밀번호는 5글자~20글자로 구성되어야 합니다"
                }
            }
            .asDriver(onErrorJustReturn: "비밀번호는 5글자~20글자로 구성되어야 합니다")

        let nicknameValidationResult = input.nicknameText
            .map { nickname in
                if nickname.count >= 3 && nickname.count < 10 && nickname.allSatisfy({ $0.isLowercase }) {
                    nicknameValid.onNext(true)
                    return "사용할 수 있는 ID입니다"
                } else {
                    nicknameValid.onNext(false)
                    return "ID는 3글자~10글자의 영문으로만 구성되어야 합니다"
                }
            }
            .asDriver(onErrorJustReturn: "ID는 3글자~10글자의 영문으로만 구성되어야 합니다")

        let signUpEnabled = Observable.combineLatest(emailValid, passwordValid, nicknameValid) { $0 && $1 && $2 }
            .asDriver(onErrorJustReturn: false)

        input.signUpButtonTapped
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText, input.nicknameText))
            .map { SignUpQuery(email: $0.0, password: $0.1, nick: $0.2) }
            .flatMapLatest { signUpQuery in
                NetworkManager.createAccount(query: signUpQuery)
                    .asObservable()
                    .materialize()
            }
            .subscribe(with: self) { owner, signInModel in
                signUpSuccessTrigger.accept(())
            } onError: { owner, error in
                print("error about signup")
            }
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
