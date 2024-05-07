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

class FeedPageViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    var next_cursor: String?
    private var isFetching = BehaviorSubject<Bool>(value: false)
    private var currentLocation: CLLocation?

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
        print("Current location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func transform(input: Input) -> Output {
        let fetchRequest = Observable.merge(
            input.trigger.map { _ in ViewPostQuery(product_id: "ker0r0", next: self.next_cursor, limit: "7") },
            input.fetchNextPage.map { _ in ViewPostQuery(product_id: "ker0r0", next: self.next_cursor, limit: "7") },
            input.newPostAdded.map { _ in ViewPostQuery(product_id: "ker0r0", next: nil, limit: "7") }
        )

        let posts = fetchRequest
            .flatMapLatest { query -> Observable<FeedModel> in
                self.isFetching.onNext(true)
                return NetworkManager.performRequest(route: Router.viewPost(query: query), dataType: FeedModel.self)
                    .asObservable()
                    .catchAndReturn(FeedModel(data: [], nextCursor: nil))
            }
            .do(onNext: { [weak self] feedModel in
                if let nextCursor = feedModel.nextCursor, nextCursor != "0" {
                    self?.next_cursor = nextCursor
                } else {
                    self?.next_cursor = nil  // "0" 또는 유효하지 않은 커서를 nil로 설정
                }
                self?.isFetching.onNext(false)
            })
            .map { feedModel -> [Post] in
                guard let currentLocation = self.currentLocation else { return [] }
                return feedModel.data.filter { post in
                    guard let lat = Double(post.content1 ?? ""), let lon = Double(post.content2 ?? "") else { return false }
                    let postLocation = CLLocation(latitude: lat, longitude: lon)
                    let distance = postLocation.distance(from: currentLocation)
                    guard let postDate = post.createdAt.toDate() else { return false }
                    let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: postDate, to: Date())
                    let timeDiff = (timeComponents.hour ?? 0) * 60 + (timeComponents.minute ?? 0)
                    
                    print("Post \(post.postID) time difference: \(timeDiff) minutes")

                    let timeCondition = timeDiff <= (23 * 60 + 59)
                    let contentCondition = post.content3 == "1"
                    let contentCondition2 = post.content3 == "2"
                    
                    return (distance <= 1000 && timeCondition) || contentCondition || (contentCondition2 && distance <= 1000 && timeCondition)
                }
            }
            .asDriver(onErrorJustReturn: [])

        return Output(posts: posts)
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self)
    }
}

