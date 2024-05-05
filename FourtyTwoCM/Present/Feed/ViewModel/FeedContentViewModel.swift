//
//  FeedContentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class FeedContentViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private var post: BehaviorSubject<Post>

    var isLiked = BehaviorSubject<Bool>(value: false)
    
    var postDeleteSuccess = PublishSubject<Void>()
    
    var errorMessage = PublishSubject<String>()
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let likeBtnTapped: Observable<Void>
        let ellipsisBtnTapped: Observable<Void>
    }

    struct Output {
        let content: Driver<String>
        let nickname: Driver<String>
        let profileImageUrl: Driver<String?>
        let postImageUrl: Driver<String?>
        let likeStatus: Driver<Bool>
        let likeButtonImage: Driver<String>  // 좋아요 버튼 이미지 이름을 제공
        let ellipsisVisibility: Driver<Bool>
        let goReservationVisibility: Driver<Bool>
        let showActionSheet: Driver<Void>
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
        
        let ellipsisVisibility = post.map { $0.creator.userID != userID } // isHidden의 default가 true라서 반대로 넘겨줌
            .asDriver(onErrorJustReturn: false)

        let content = post.map { $0.content }.asDriver(onErrorJustReturn: "")
        let nickname = post.map { $0.creator.nick }.asDriver(onErrorJustReturn: "")
        let profileImageUrl = post
            .map { $0.creator.profileImage?.prependBaseURL() }
            .asDriver(onErrorJustReturn: nil)
        let postImageUrl = post
            .map { $0.files.first?.prependBaseURL() }
            .asDriver(onErrorJustReturn: nil)
        
        let showActionSheet = input.ellipsisBtnTapped
                    .asDriver(onErrorJustReturn: ())
        
        let goReservationVisibility = post
                .map { $0.content3 != "2" }
                .asDriver(onErrorJustReturn: false)

        return Output(
            content: content,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            postImageUrl: postImageUrl,
            likeStatus: likeStatus, 
            likeButtonImage: likeButtonImage,
            ellipsisVisibility: ellipsisVisibility,
            goReservationVisibility: goReservationVisibility,
            showActionSheet: showActionSheet
        )
    }
    
    private func toggleLikeStatus(for postID: String, newStatus: Bool) -> Observable<Bool> {
        let query = LikeQuery(like_status: newStatus)
        return NetworkManager.performRequest(route: Router.likePost(postId: postID, query: query), dataType: LikeModel.self)
            .map { $0.likeStatus }
            .asObservable()
            .catch { [weak self] error -> Observable<Bool> in
                if let apiError = error as? APIError, apiError.checkAccessTokenError() {
                    self?.errorMessage.onNext("인증 오류가 발생했습니다.")
                }
                return .just(false)
            }
    }
    
    func confirmDeletion() {
        guard let postID = try? post.value().postID else { return }
        NetworkManager.requestDeletePost(postID: postID)
            .subscribe(onSuccess: { [weak self] _ in
                self?.postDeleteSuccess.onNext(())
            }, onFailure: { [weak self] error in
                if let apiError = error as? APIError, apiError.checkAccessTokenError() {
                    self?.errorMessage.onNext("인증 오류가 발생했습니다.")
                }
            })
            .disposed(by: disposeBag)
    }

}

extension String {
    func prependBaseURL() -> String {
        return BaseURL.baseURL.rawValue + "/" + self
    }
}
