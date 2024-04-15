//
//  SignInViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let loginButtonTapped: Observable<Void>
    }
    
    struct Output {
        let loginValidation: Driver<Bool>   // UI적인 handling을 하게 될 거라서 driver 채택
        let loginSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let loginValid = BehaviorRelay(value: false)
        let loginSuccessTrigger = PublishRelay<Void>()
        
        let loginObservable = Observable.combineLatest(input.emailText, input.passwordText)
            .map { email, password in
                return SigninQuery(email: email, password: password)
            }
        
        loginObservable.bind(with: self) { owner, login in
            if login.email.contains("@") && login.password.count > 5 {
                loginValid.accept(true)
            } else {
                loginValid.accept(false)
            }
        }
        .disposed(by: disposeBag)
        
        // loginButtonTapped - 네트워킹
        
        
        return Output(loginValidation: loginValid.asDriver(), loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
    
}

