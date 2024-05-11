//
//  CommentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import Foundation
import RxSwift
import RxCocoa

class CommentViewModel: ViewModelType {
    struct Input {
        let closeTrigger: Observable<Void>
    }

    struct Output {
        let dismiss: Driver<Void>
    }
    
    var disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let dismissAction = input.closeTrigger
            .asDriver(onErrorJustReturn: ())
        
        return Output(dismiss: dismissAction)
    }
}

