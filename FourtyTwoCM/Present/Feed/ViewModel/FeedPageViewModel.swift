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
    let errorMessage = PublishSubject<String>()

    struct Input {
        let trigger: Observable<Void>
        let fetchNextPage: Observable<Void>
    }

    struct Output {
        let posts: Driver<[Post]>
        let errorMessage: Driver<String>
    }

    func transform(input: Input) -> Output {
        let posts = BehaviorSubject<[Post]>(value: [])

        input.trigger
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                self.currentPage.onNext(nil)
                return self.fetchPosts()
            }
            .bind(to: posts)
            .disposed(by: disposeBag)

        input.fetchNextPage
            .withLatestFrom(currentPage)
            .filter { $0 != "0" }
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                return self.fetchPosts()
            }
            .withLatestFrom(posts) { (newPosts, existingPosts) in
                return existingPosts + newPosts
            }
            .bind(to: posts)
            .disposed(by: disposeBag)

        return Output(
            posts: posts.asDriver(onErrorJustReturn: []),
            errorMessage: errorMessage.asDriver(onErrorJustReturn: "")
        )
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
                    self?.errorMessage.onNext(apiError.errorMessage)
                } else {
                    self?.errorMessage.onNext("알 수 없는 오류가 발생했습니다.")
                }
                return .just([])
            }
    }
}
