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
            .debounce(.seconds(1), scheduler: MainScheduler.instance)   // 한 번 탭 누르면 1초 동안 탭 못 누르게
            .withLatestFrom(loginObservable)
            .flatMap { signInQuery in
                return NetworkManager.createLogin(query: signInQuery)
            }
            .subscribe(with: self) { owner, signInModel in
                loginSuccessTrigger.accept(())
            } onError: { owner, error in
                print("로그인 버튼에서 에러: \(error)")
            }
            .disposed(by: disposeBag)
        
        
        return Output(loginValidation: loginValid.asDriver(), loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
    
}

