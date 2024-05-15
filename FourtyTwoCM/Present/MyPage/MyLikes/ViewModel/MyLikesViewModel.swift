//
//  LikesViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import RxSwift
import RxCocoa

class MyLikesViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private let currentPage = BehaviorSubject<String?>(value: nil)
    private let isLoading = BehaviorSubject<Bool>(value: false)
    let errorMessage = PublishSubject<String>()
    
    struct Input {
        let trigger: Observable<Void>
        let loadNextPage: Observable<Void>
    }
    
    struct Output {
        let posts: Driver<[Post]>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let posts = BehaviorSubject<[Post]>(value: [])
        
        Observable.merge(input.trigger, input.loadNextPage)
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                return self.fetchPosts()
            }
            .scan([], accumulator: { old, new in return old + new })
            .bind(to: posts)
            .disposed(by: disposeBag)
        
        return Output(
            posts: posts.asDriver(onErrorJustReturn: []),
            errorMessage: errorMessage.asDriver(onErrorJustReturn: "")
        )
    }
    
    private func fetchPosts() -> Observable<[Post]> {
        guard ((try? isLoading.value()) != nil), (try? currentPage.value()) != "0" else {
            return .empty()
        }
        
        isLoading.onNext(true)
        let query = ViewMyLikesQuery(next: try? currentPage.value(), limit: "6")
        
        return NetworkManager.performRequest(route: .viewMyLikes(query: query), dataType: FeedModel.self)
            .asObservable()
            .do(onDispose: { [weak self] in self?.isLoading.onNext(false) })
            .flatMap { [weak self] feedModel -> Observable<[Post]> in
                if feedModel.nextCursor == "0" {
                    self?.currentPage.onNext("0")
                } else {
                    self?.currentPage.onNext(feedModel.nextCursor)
                }
                return .just(feedModel.data)
            }
            .catch { [weak self] error in
                if let apiError = error as? APIError {
                    self?.errorMessage.onNext(apiError.errorMessage)
                } else {
                    self?.errorMessage.onNext("알 수 없는 오류가 발생했습니다.")
                }
                return .just([])
            }
    }
}
