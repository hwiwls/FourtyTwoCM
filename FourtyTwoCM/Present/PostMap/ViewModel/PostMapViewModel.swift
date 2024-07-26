//
//  PostMapViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostMapViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let postsSubject = BehaviorRelay<[Post]>(value: [])
    private let errorMessageSubject = PublishRelay<String>()
    
    struct Input {
        let loadTrigger: Observable<Void>
    }
    
    struct Output {
        let posts: Driver<[Post]>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        input.loadTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .just([]) }
                return self.fetchPosts()
            }
            .bind(to: postsSubject)
            .disposed(by: disposeBag)
        
        return Output(
            posts: postsSubject.asDriver(onErrorJustReturn: []),
            errorMessage: errorMessageSubject.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
    
    private func fetchPosts() -> Observable<[Post]> {
        let query = ViewPostQuery(product_id: "ker0r0", next: nil, limit: "1000")
        
        return NetworkManager.performRequest(route: .viewPost(query: query), dataType: FeedModel.self)
            .asObservable()
            .flatMap { feedModel -> Observable<[Post]> in
                return .just(feedModel.data)
            }
            .catch { [weak self] error in
                guard let self = self else { return .just([]) }
                if let apiError = error as? APIError {
                    self.errorMessageSubject.accept(apiError.errorMessage)
                } else {
                    self.errorMessageSubject.accept("알 수 없는 오류가 발생했습니다.")
                }
                return .just([])
            }
    }
}
