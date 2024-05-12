//
//  FeedPageViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class FeedPageViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var next_cursor: String?
    private var currentLocation: CLLocation?
    private var minimumRequiredPosts = 30 // 최소로 가져와야 하는 포스트 수를 지정.

    struct Input {
        let trigger: Observable<Void>
        let fetchNextPage: Observable<Void>
        let newPostAdded: Observable<Void>
    }

    struct Output {
        let posts: Driver<[Post]>
    }

    func setCurrentLocation(_ location: CLLocation) {
        currentLocation = location
        print("현재 위치 위도: \(location.coordinate.latitude), 현재 위치 경도: \(location.coordinate.longitude)")
    }

    func transform(input: Input) -> Output {
        let initialQuery = ViewPostQuery(product_id: "ker0r0", next: nil, limit: "5")
        
        let fetchRequest = Observable.merge(
            input.trigger.map { _ in initialQuery },
            input.fetchNextPage.map { _ in ViewPostQuery(product_id: "ker0r0", next: self.next_cursor, limit: "5") },
            input.newPostAdded.map { _ -> ViewPostQuery in
                self.next_cursor = nil  // 새 게시글 추가 시 커서 리셋
                return initialQuery
            }
        )

        let posts = fetchRequest
            .flatMapLatest { query -> Observable<[Post]> in
                self.performRequestWithQuery(query)
                    .asObservable()
                    .flatMap { feedModel -> Observable<[Post]> in
                        if let nextCursor = feedModel.nextCursor, nextCursor != "0" {
                            self.next_cursor = nextCursor
                        } else {
                            self.next_cursor = nil
                        }
                        let filteredPosts = feedModel.data.filter { self.isValid(post: $0) }
                        return self.fetchPostsIfNeeded(currentPosts: filteredPosts)
                    }
                    .catch { error -> Observable<[Post]> in
                        print("Error: \(error.localizedDescription)")
                        return .just([])
                    }
            }
            .asDriver(onErrorJustReturn: [])

        return Output(posts: posts)
    }


    private func performRequestWithQuery(_ query: ViewPostQuery) -> Single<FeedModel> {
        return NetworkManager.performRequest(route: Router.viewPost(query: query), dataType: FeedModel.self)
            .map { feedModel -> FeedModel in
                if let nextCursor = feedModel.nextCursor, nextCursor != "0" {
                    self.next_cursor = nextCursor
                } else {
                    self.next_cursor = nil  // 여기에서 커서를 nil로 설정
                }
                return feedModel
            }
    }

    private func fetchPostsIfNeeded(currentPosts: [Post]) -> Observable<[Post]> {
        let requiredPostsCount = minimumRequiredPosts
        return Observable.create { [weak self] observer in
            var accumulatedPosts = currentPosts

            func loadNextPage() {
                guard let self = self,
                      let nextCursor = self.next_cursor,
                      nextCursor != "0" else {
                    observer.onNext(accumulatedPosts)
                    observer.onCompleted()
                    return
                }

                let query = ViewPostQuery(product_id: "ker0r0", next: nextCursor, limit: "5")
                self.performRequestWithQuery(query)
                    .asObservable()
                    .subscribe(onNext: { feedModel in
                        let validPosts = feedModel.data.filter { self.isValid(post: $0) }
                        accumulatedPosts.append(contentsOf: validPosts)

                        if accumulatedPosts.count >= requiredPostsCount || feedModel.nextCursor == "0" {
                            observer.onNext(accumulatedPosts)
                            observer.onCompleted()
                        } else {
                            self.next_cursor = feedModel.nextCursor
                            loadNextPage()
                        }
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            }

            loadNextPage()
            return Disposables.create()
        }
    }


    private func fetchMorePosts() -> Observable<[Post]> {
        guard let nextCursor = next_cursor, nextCursor != "0" else {
            return .just([])  // 여기에서 빈 배열 반환하도록 수정
        }
        let query = ViewPostQuery(product_id: "ker0r0", next: nextCursor, limit: "5")
        return performRequestWithQuery(query)
            .asObservable()
            .map { feedModel -> [Post] in
                return feedModel.data.filter { self.isValid(post: $0) }
            }
            .catchAndReturn([])
    }

    private func isValid(post: Post) -> Bool {
        guard let lat = Double(post.content1 ?? ""), let lon = Double(post.content2 ?? ""),
              let currentLocation = self.currentLocation else {
            return false
        }
        let postLocation = CLLocation(latitude: lat, longitude: lon)
        let distance = postLocation.distance(from: currentLocation)
        guard let postDate = post.createdAt.toDate() else {
            return false
        }
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: postDate, to: Date())
        let timeDiff = (timeComponents.hour ?? 0) * 60 + (timeComponents.minute ?? 0)

        let timeCondition = timeDiff <= (23 * 60 + 59)
        let contentCondition = post.content3 == "1"

        return (distance <= 1000 && timeCondition) || contentCondition
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self)
    }
}
