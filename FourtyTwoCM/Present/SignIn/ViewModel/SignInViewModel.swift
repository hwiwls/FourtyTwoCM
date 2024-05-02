//
//  SignInViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel {

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
        let emailAndPassword = Observable.combineLatest(input.emailText, input.passwordText)
            .map { SignInQuery(email: $0, password: $1) }

        let isLoginButtonEnabled = emailAndPassword
            .map { !$0.email.isEmpty && !$0.password.isEmpty }
            .asDriver(onErrorJustReturn: false)

        let signInResult = input.signInButtonTapped
            .withLatestFrom(emailAndPassword)
            .flatMapLatest { query in
                NetworkManager.performRequest(route: Router.login(query: query), dataType: SignInModel.self)
                    .asObservable()
                    .materialize()
            }
            .share()

        let signInSuccess = signInResult
            .compactMap { $0.element }
            .do(onNext: { signInModel in
                // 토큰 저장 로직
                do {
                    try Keychain.shared.saveToken(kind: .accessToken, token: signInModel.accessToken)
                    try Keychain.shared.saveToken(kind: .refreshToken, token: signInModel.refreshToken)
                    UserDefaults.standard.set(signInModel.user_id, forKey: "userID")
                } catch {
                    print("토큰 저장 실패: \(error)")
                }
            })
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: .empty())

        let signInFailure = signInResult
            .compactMap { $0.error }
            .map { error in
                switch error {
                case APIError.unauthorized:
                    return "계정 혹은 비밀번호를 확인해주세요"
                default:
                    return "로그인 오류가 발생했습니다"
                }
            }
            .asDriver(onErrorJustReturn: "알 수 없는 에러가 발생했습니다.")
        
        let signUpTrigger = input.signUpButtonTapped
            .asDriver(onErrorJustReturn: ())

        return Output(isLoginButtonEnabled: isLoginButtonEnabled, signInSuccess: signInSuccess, signInFailure: signInFailure, signUpTrigger: signUpTrigger)
    }
}

