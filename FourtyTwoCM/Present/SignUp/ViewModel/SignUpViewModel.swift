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
        let signUpButtonTapped: Observable<Void>
        let emailValidationButtonTapped: Observable<Void>
        let nicknameText: Observable<String>
    }
    
    struct Output {
        let signUpValidation: Driver<Bool>
        let signUpSuccessTrigger: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let signUpValid = BehaviorRelay(value: false)
        let signUpSuccessTrigger = PublishRelay<Void>()
        let emailValid = BehaviorRelay(value: false)
        
        return Output(
            signUpValidation: signUpValid.asDriver(),
            signUpSuccessTrigger: signUpSuccessTrigger.asDriver(onErrorJustReturn: ())
            )
    }
    
}
