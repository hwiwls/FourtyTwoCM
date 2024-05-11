//
//  CommentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel: ViewModelType {
    struct Input {
        let closeTrigger: Observable<Void>
        let textInput: Observable<String>
        let keyboardDismissalTrigger: Observable<Void>
    }

    struct Output {
        let dismiss: Driver<Void>
        let submitButtonVisible: Driver<Bool>
        let keyboardDismiss: Driver<Void>
    }
    
    var disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let dismissAction = input.closeTrigger
            .asDriver(onErrorJustReturn: ())

        let submitButtonVisible = input.textInput
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        
        let keyboardDismiss = input.keyboardDismissalTrigger
                    .asDriver(onErrorJustReturn: ())

        return Output(dismiss: dismissAction, submitButtonVisible: submitButtonVisible, keyboardDismiss: keyboardDismiss)
            
    }
}
