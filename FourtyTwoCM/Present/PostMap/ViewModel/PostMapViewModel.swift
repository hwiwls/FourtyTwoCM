//
//  PostMapViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostMapViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let posts: Driver<[Post]>
    }
    
    private let postsSubject = BehaviorRelay<[Post]>(value: [])
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.loadTrigger
            .flatMapLatest { _ in
                self.fetchPosts()
            }
            .drive(postsSubject)
            .disposed(by: disposeBag)
        
        return Output(
            posts: postsSubject.asDriver()
        )
    }
    
    private func fetchPosts() -> Driver<[Post]> {
        let query = ViewPostQuery(product_id: "ker0r0", next: nil, limit: "1000")
        
        return NetworkManager.performRequest(route: .viewPost(query: query), dataType: FeedModel.self)
            .asObservable()
            .flatMap { feedModel -> Observable<[Post]> in
                return .just(feedModel.data)
            }
            .asDriver(onErrorJustReturn: [])
    }
}
