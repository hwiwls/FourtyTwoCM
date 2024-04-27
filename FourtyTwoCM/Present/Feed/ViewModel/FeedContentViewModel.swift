//
//  FeedContentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa

class FeedContentViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    var post: BehaviorSubject<Post>
    
    var content: Observable<String>
    var nickname: Observable<String>
    var profileImageUrl: Observable<String?>
    var postImageUrl: Observable<String?>
    
    let isLiked = BehaviorSubject<Bool>(value: false)
    
    
    init(post: Post) {
        self.post = BehaviorSubject<Post>(value: post)
        if let userID = UserDefaults.standard.string(forKey: "userID"),
               let isLikedByUser = post.likes?.contains(userID) {
            self.isLiked.onNext(isLikedByUser)
        }
        
        content = self.post.map { $0.content }.asObservable()
        nickname = self.post.map { $0.creator.nick }.asObservable()
        profileImageUrl = self.post.map { post in
            guard let profileImage = post.creator.profileImage else { return nil }
            return BaseURL.baseURL.rawValue + "/" + profileImage
        }.asObservable()
        postImageUrl = self.post.map { post in
            guard let firstFile = post.files.first else { return nil }
            return BaseURL.baseURL.rawValue + "/" + firstFile
        }.asObservable()
    }
    
    var postID: Observable<String> {
        return post.map { $0.postID }
    }
    
    struct Input {
        let likeBtnTapped: Observable<Void>
    }

    struct Output {
        let likeStatus: Driver<Bool>
    }

    func transform(input: Input) -> Output {
        // 좋아요 버튼 탭을 감지하고 상태를 토글
        let likeStatus = input.likeBtnTapped
            .withLatestFrom(isLiked)  // 현재 좋아요 상태를 가져오기
            .flatMapLatest { [weak self] currentStatus -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                let newStatus = !currentStatus
                self.isLiked.onNext(newStatus)  // 상태 업데이트
                guard let postID = try? self.post.value().postID else {
                            return Observable.just(false)
                        }

                        return self.toggleLikeStatus(for: postID, newStatus: newStatus)
                    }
            .asDriver(onErrorJustReturn: false)

        return Output(likeStatus: likeStatus)
    }

    private func toggleLikeStatus(for postID: String, newStatus: Bool) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let query = LikeQuery(like_status: newStatus)

            NetworkManager.requestLikePost(query: query, postID: postID)
                .subscribe(onSuccess: { likeModel in
                    observer.onNext(likeModel.likeStatus)
                    observer.onCompleted()
                }, onFailure: { error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}
