//
//  SignInViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa
import Toast

final class SignInViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let loginButtonTapped: Observable<Void>
        let signUpButtonTapped: Observable<Void>
    }
    
    struct Output {
        let loginValidation: Driver<Bool>
        let loginSuccessTrigger: Driver<Void>
        let toastMessage: Driver<String>
        let signUpTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let loginValid = BehaviorRelay(value: false)
        let loginSuccessTrigger = PublishRelay<Void>()
        let toastMessageRelay = PublishRelay<String>()
        
        let loginObservable = Observable.combineLatest(input.emailText, input.passwordText)
            .map { email, password in
                return SignInQuery(email: email, password: password)
            }
        
        loginObservable.bind(with: self) { owner, login in
            if login.email.contains("@") && login.password.count > 5 && login.password.count < 20 {
                loginValid.accept(true)
            } else {
                loginValid.accept(false)
            }
        }
        .disposed(by: disposeBag)
        
        input.loginButtonTapped
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(loginObservable)
            .flatMap { signInQuery in
                return NetworkManager.createLogin(query: signInQuery)
            }
            .subscribe(with: self) { owner, signInModel in
                loginSuccessTrigger.accept(())
            } onError: { owner, error in
                if let networkError = error as? NetworkError, networkError == .unauthorized {
                    toastMessageRelay.accept("계정 혹은 비밀번호를 확인해주세요")
                } else {
                    toastMessageRelay.accept("로그인 오류가 발생했습니다.")
                }
            }
            .disposed(by: disposeBag)
        
        let signUpTrigger = input.signUpButtonTapped
                .asDriver(onErrorJustReturn: ())
        
        return Output(
            loginValidation: loginValid.asDriver(),
            loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()),
            toastMessage: toastMessageRelay.asDriver(onErrorJustReturn: ("알 수 없는 에러가 발생했습니다.")),
            signUpTrigger: signUpTrigger
        )
    }
    
}

