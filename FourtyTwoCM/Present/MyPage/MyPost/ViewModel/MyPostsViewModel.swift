//
//  PostsViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MyPostsViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private let currentPage = BehaviorRelay<String?>(value: nil)
    let errorMessage = PublishRelay<String>()
    
    struct Input {
        let trigger: Observable<Void>
        let loadNextPage: Observable<Void>
    }

    struct Output {
        let posts: Driver<[Post]>
        let errorMessage: Driver<String>
        let reloadTrigger: Driver<Void>
    }

    func transform(input: Input) -> Output {
        
        let posts = BehaviorRelay<[Post]>(value: [])
        let reloadTrigger = PublishRelay<Void>()

        // 초기 데이터 로드
        input.trigger
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                self.currentPage.accept(nil)
                return self.fetchPosts()
            }
            .do(onNext: { _ in
                reloadTrigger.accept(())
            })
            .bind(to: posts)
            .disposed(by: disposeBag)

        // 페이지네이션 데이터 로드
        input.loadNextPage
            .withLatestFrom(currentPage)
            .filter { $0 != "0" } // 더 이상 로드할 페이지가 없을 때는 요청하지 않음
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                return self.fetchPosts()
            }
            .withLatestFrom(posts) { (newPosts, existingPosts) in
                return existingPosts + newPosts
            }
            .do(onNext: { _ in
                reloadTrigger.accept(())
            })
            .bind(to: posts)
            .disposed(by: disposeBag)

        return Output(
            posts: posts.asDriver(onErrorJustReturn: []),
            errorMessage: errorMessage.asDriver(onErrorJustReturn: ""),
            reloadTrigger: reloadTrigger.asDriver(onErrorJustReturn: ())
        )
    }

    private func fetchPosts() -> Observable<[Post]> {
        let query = ViewMyPostsQuery(product_id: "ker0r0", next: currentPage.value, limit: "10")

        print("현재 페이지: \(String(describing: currentPage.value))")
        return NetworkManager.performRequest(route: .viewMyPosts(userID: UserDefaults.standard.string(forKey: "userID") ?? "", query: query), dataType: FeedModel.self)
            .asObservable()
            .flatMap { [weak self] feedModel -> Observable<[Post]> in
                if feedModel.nextCursor == "0" {
                    self?.currentPage.accept("0")
                } else {
                    self?.currentPage.accept(feedModel.nextCursor)
                }
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
