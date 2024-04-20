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
    }
    
    struct Output {
        let signUpValidation: Driver<Bool>
        let signUpSuccessTrigger: Driver<Void>
        let emailValid: Driver<Bool>
    }

    func transform(input: Input) -> Output {
        let signUpValid = BehaviorRelay(value: false)
        let signUpSuccessTrigger = PublishRelay<Void>()
        let emailValid = BehaviorRelay(value: false)
        
        return Output(
            signUpValidation: signUpValid.asDriver(),
            signUpSuccessTrigger: signUpSuccessTrigger.asDriver(onErrorJustReturn: ()),
            emailValid: emailValid.asDriver())
    }
    
}
