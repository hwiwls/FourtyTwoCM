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
        let errorMessage: Driver<String>
    }
    
    private let postsSubject = BehaviorRelay<[Post]>(value: [])
    private let errorMessageSubject = PublishRelay<String>()
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.loadTrigger
            .flatMapLatest { _ in
                self.fetchPosts()
            }
            .drive(postsSubject)
            .disposed(by: disposeBag)
        
        return Output(
            posts: postsSubject.asDriver(),
            errorMessage: errorMessageSubject.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
    
    private func fetchPosts() -> Driver<[Post]> {
        let query = ViewPostQuery(product_id: "ker0r0", next: nil, limit: "1000")
        
        return NetworkManager.performRequest(route: .viewPost(query: query), dataType: FeedModel.self)
            .asObservable()
            .flatMap { feedModel -> Observable<[Post]> in
                return .just(feedModel.data)
            }
            .asDriver { error in
                if let apiError = error as? APIError {
                    self.errorMessageSubject.accept(apiError.errorMessage)
                } else {
                    self.errorMessageSubject.accept("알 수 없는 오류가 발생했습니다.")
                }
                return Driver.just([])
            }
    }
}
