//
//  FeedContentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa

class FeedContentViewModel {
    var disposeBag = DisposeBag()
    
    private var post: BehaviorSubject<Post>

    var isLiked = BehaviorSubject<Bool>(value: false)
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let likeBtnTapped: Observable<Void>
    }

    struct Output {
        let content: Driver<String>
        let nickname: Driver<String>
        let profileImageUrl: Driver<String?>
        let postImageUrl: Driver<String?>
        let likeStatus: Driver<Bool>
        let likeButtonImage: Driver<String>  // 좋아요 버튼 이미지 이름을 제공
        let ellipsisVisibility: Driver<Bool>
    }

    init(post: Post) {
        self.post = BehaviorSubject<Post>(value: post)
        
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
                
                // 초기 좋아요 상태 설정
                let initialIsLiked = post.likes?.contains(userID) ?? false
                self.isLiked.onNext(initialIsLiked)
    }

    func transform(input: Input) -> Output {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        
        let likeStatus = input.likeBtnTapped
                .withLatestFrom(isLiked) { !$1 }
                .flatMapLatest { [weak self] newStatus -> Observable<Bool> in
                    guard let self = self, let postID = try? self.post.value().postID else {
                        return .just(false)
                    }
                    return self.toggleLikeStatus(for: postID, newStatus: newStatus)
                }
                .do(onNext: isLiked.onNext)
                .asDriver(onErrorJustReturn: false)
            
            let likeButtonImage = isLiked
                .map { $0 ? "heart.fill" : "heart" }
                .asDriver(onErrorJustReturn: "heart")
        let ellipsisVisibility = post.map { $0.creator.userID == userID }
            .asDriver(onErrorJustReturn: false)

        let content = post.map { $0.content }.asDriver(onErrorJustReturn: "")
        let nickname = post.map { $0.creator.nick }.asDriver(onErrorJustReturn: "")
        let profileImageUrl = post.map { post in post.creator.profileImage.map { BaseURL.baseURL.rawValue + "/" + $0 } }.asDriver(onErrorJustReturn: nil)
        let postImageUrl = post.map { post in post.files.first.map { BaseURL.baseURL.rawValue + "/" + $0 } }.asDriver(onErrorJustReturn: nil)
        

        return Output(
            content: content,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            postImageUrl: postImageUrl,
            likeStatus: likeStatus, 
            likeButtonImage: likeButtonImage,
            ellipsisVisibility: ellipsisVisibility
        )
    }

    private func toggleLikeStatus(for postID: String, newStatus: Bool) -> Observable<Bool> {
        let query = LikeQuery(like_status: newStatus)
        return NetworkManager.requestLikePost(query: query, postID: postID)
            .map { $0.likeStatus }
            .asObservable()
            .catchAndReturn(false)
    }
}
