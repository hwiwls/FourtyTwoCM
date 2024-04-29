//
//  FeedPageViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

class FeedPageViewModel: ViewModelType {
    struct Input {
        let trigger: Observable<Void>
    }

    struct Output {
        let posts: Driver<[Post]>
    }

    var disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let posts = input.trigger
            .flatMapLatest {
                NetworkManager.requestViewPost(query: ViewPostQuery(product_id: "ker0r0"))
                    .asObservable()
            }
            .map { $0.data }
            .asDriver(onErrorJustReturn: [])

        return Output(posts: posts)
    }
}
