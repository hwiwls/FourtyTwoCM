//
//  LikesViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import RxSwift
import RxCocoa

final class MyLikesViewModel: ViewModelType {
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
                print("Trigger: viewWillAppear")
                self.currentPage.onNext(nil)
                return self.fetchPosts(reset: true)
            }
            .do(onNext: { _ in
                reloadTrigger.onNext(())
            })
            .bind(to: posts)
            .disposed(by: disposeBag)

        input.loadNextPage
            .withLatestFrom(currentPage)
            .filter { $0 != "0" }  // 더 이상 로드할 페이지가 없을 때는 요청하지 않음
            .flatMapLatest { [weak self] _ -> Observable<[Post]> in
                guard let self = self else { return .empty() }
                print("Trigger: loadNextPage")
                return self.fetchPosts(reset: false)
            }
            .withLatestFrom(posts) { (newPosts, existingPosts) in
                return existingPosts + newPosts
            }
            .do(onNext: { _ in
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

    private func fetchPosts(reset: Bool) -> Observable<[Post]> {
        guard ((try? isLoading.value()) == false) else {
            print("fetchPosts called but already loading")
            return .empty()
        }

        if reset {
            currentPage.onNext(nil)
            print("Resetting currentPage")
        }

        isLoading.onNext(true)
        print("Fetching posts with currentPage: \(String(describing: try? currentPage.value()))")
        let query = ViewMyLikesQuery(next: try? currentPage.value(), limit: "6")

        return NetworkManager.performRequest(route: .viewMyLikes(query: query), dataType: FeedModel.self)
            .asObservable()
            .do(onDispose: { [weak self] in
                self?.isLoading.onNext(false)
                print("Fetch posts completed")
            })
            .flatMap { [weak self] feedModel -> Observable<[Post]> in
                if feedModel.nextCursor == "0" {
                    self?.currentPage.onNext("0")
                    print("No more pages to load")
                } else {
                    self?.currentPage.onNext(feedModel.nextCursor)
                    print("Next page cursor: \(feedModel.nextCursor)")
                }
                return .just(feedModel.data)
            }
            .catch { [weak self] error in
                print("Error fetching posts: \(error)")
                if let apiError = error as? APIError {
                    self?.errorMessage.onNext(apiError.errorMessage)
                } else {
                    self?.errorMessage.onNext("알 수 없는 오류가 발생했습니다.")
                }
                return .just([])
            }
    }
}
