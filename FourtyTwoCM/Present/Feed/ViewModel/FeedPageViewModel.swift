//
//  FeedPageViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FeedPageViewModel: ViewModelType {

    var disposeBag = DisposeBag()
    private let currentPage = BehaviorSubject<String?>(value: nil)
    private let isLoading = BehaviorSubject<Bool>(value: false)
    let errorMessage = PublishRelay<String>()

    struct Input {
        let trigger: Observable<Void>
        let fetchNextPage: Observable<Void>
    }

    struct Output {
        let posts: Driver<[Post]>
        let errorMessage: Driver<String>
    }

    func transform(input: Input) -> Output {
        let posts = BehaviorRelay<[Post]>(value: [])
        
        let loadInitialPosts = input.trigger
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                self.currentPage.onNext(nil)
                return self.fetchPosts()
            }

        let loadMorePosts = input.fetchNextPage
            .withLatestFrom(currentPage)
            .filter { $0 != "0" }
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                return self.fetchPosts()
            }

        Observable.merge(loadInitialPosts, loadMorePosts)
            .scan([]) { currentPosts, newPosts in
                return currentPosts + newPosts
            }
            .bind(to: posts)
            .disposed(by: disposeBag)
        
        let postsDriver = posts.asDriver(onErrorJustReturn: [])
        let errorMessageDriver = errorMessage.asDriver(onErrorJustReturn: "")

        return Output(posts: postsDriver, errorMessage: errorMessageDriver)
    }

    private func fetchPosts() -> Observable<[Post]> {
        let query = ViewPostQuery(product_id: "ker0r0", next: try? currentPage.value(), limit: "5")

        return NetworkManager.performRequest(route: .viewPost(query: query), dataType: FeedModel.self)
            .asObservable()
            .do(onSubscribe: { [weak self] in
                self?.isLoading.onNext(true)
            }, onDispose: { [weak self] in
                self?.isLoading.onNext(false)
            })
            .flatMap { [weak self] feedModel -> Observable<[Post]> in
                self?.currentPage.onNext(feedModel.nextCursor == "0" ? "0" : feedModel.nextCursor)
                return .just(feedModel.data)
            }
            .catch { [weak self] error in
                if let apiError = error as? APIError {
                    self?.errorMessage.accept(apiError.errorMessage)
                } else {
                    self?.errorMessage.accept("알 수 없는 오류가 발생했습니다.")
                }
                return .just([])
            }
    }
}
