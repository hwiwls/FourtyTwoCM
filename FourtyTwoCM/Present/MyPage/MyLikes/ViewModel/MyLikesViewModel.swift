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
    let refreshTrigger = PublishSubject<Void>()
    
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
        let posts = BehaviorSubject<[Post]>(value: [])
        let reloadTrigger = PublishSubject<Void>()
        
        input.trigger
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                self.currentPage.onNext(nil) // currentPage 초기화
                return self.fetchPosts()
            }
            .do(onNext: { _ in
                print("Reload trigger called")
                reloadTrigger.onNext(())
            })
            .bind(to: posts)
            .disposed(by: disposeBag)
        
        input.loadNextPage
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                return self.fetchPosts()
            }
            .withLatestFrom(posts) { (newPosts, existingPosts) in
                return existingPosts + newPosts
            }
            .do(onNext: { _ in
                print("Reload trigger called")
                reloadTrigger.onNext(())
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
        guard ((try? isLoading.value()) != nil) else {
            return .empty()
        }
        
        print("Fetching posts")
        
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
