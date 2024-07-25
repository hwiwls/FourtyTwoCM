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
        let signInButtonTapped: Observable<Void>
        let signUpButtonTapped: Observable<Void>
    }

    struct Output {
        let isLoginButtonEnabled: Driver<Bool>
        let signInSuccess: Driver<Void>
        let signInFailure: Driver<String>
        let signUpTrigger: Driver<Void>
    }

    func transform(input: Input) -> Output {
        
        let isLoginButtonEnabled = BehaviorRelay(value: false)
        let signInSuccessTrigger = PublishRelay<Void>()
        let signInFailureRelay = PublishRelay<String>()
        
        let emailAndPassword = Observable.combineLatest(input.emailText, input.passwordText)
            .map { SignInQuery(email: $0, password: $1) }

        emailAndPassword
            .map { !$0.email.isEmpty && !$0.password.isEmpty }
            .bind(to: isLoginButtonEnabled)
            .disposed(by: disposeBag)
        
        input.signInButtonTapped
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(emailAndPassword)
            .flatMapLatest { query in
                NetworkManager.performRequest(route: Router.login(query: query), dataType: SignInModel.self)
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                switch event {
                case .next(let signInModel):
                    do {
                        try Keychain.shared.saveToken(kind: .accessToken, token: signInModel.accessToken)
                        try Keychain.shared.saveToken(kind: .refreshToken, token: signInModel.refreshToken)
                        UserDefaults.standard.set(signInModel.user_id, forKey: "userID")
                        
                        _ = RealmManager.shared.configureRealm(for: signInModel.user_id)
                        
                        signInSuccessTrigger.accept(())
                    } catch {
                        print("토큰 저장 실패: \(error)")
                        signInFailureRelay.accept("토큰 저장 실패")
                    }
                case .error(let error):
                    if let apiError = error as? APIError {
                        signInFailureRelay.accept(apiError.errorMessage)
                    } else {
                        signInFailureRelay.accept("알 수 없는 오류가 발생했습니다.")
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        let signUpTrigger = input.signUpButtonTapped
            .asDriver(onErrorJustReturn: ())

        return Output(
            isLoginButtonEnabled: isLoginButtonEnabled.asDriver(),
            signInSuccess: signInSuccessTrigger.asDriver(onErrorJustReturn: ()),
            signInFailure: signInFailureRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다."),
            signUpTrigger: signUpTrigger
        )
    }
}
