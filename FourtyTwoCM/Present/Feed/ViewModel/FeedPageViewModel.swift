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
    var disposeBag = DisposeBag()
    
    struct Input {
        let trigger: Observable<Void>
        let fetchNextPage: Observable<Void>
    }

    struct Output {
        let posts: Driver<[Post]>
       
    }

    private var next_cursor: String?
    private var isFetching = BehaviorSubject<Bool>(value: false)

    func transform(input: Input) -> Output {
        let fetchRequest = Observable.merge(
            input.trigger.map { _ in ViewPostQuery(product_id: "ker0r0", next_cursor: self.next_cursor) },
            input.fetchNextPage.map { _ in ViewPostQuery(product_id: "ker0r0", next_cursor: self.next_cursor) }
        )

        let posts = fetchRequest
            .flatMapLatest { query -> Observable<FeedModel> in
                self.isFetching.onNext(true)
                return NetworkManager.requestViewPost(query: query)
                    .asObservable()
                    .catchAndReturn(FeedModel(data: [], nextCursor: nil))
            }
            .do(onNext: { [weak self] feedModel in
                self?.next_cursor = feedModel.nextCursor
                self?.isFetching.onNext(false)
            })
            .map { $0.data }
            .asDriver(onErrorJustReturn: [])

        return Output(posts: posts)
    }
}
