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
    
    var post: BehaviorSubject<Post>
    var isLiked = BehaviorSubject<Bool>(value: false)
    var postDeleteSuccess = PublishRelay<Void>()
    var errorMessage = PublishRelay<String>()
    private var followingStatus = BehaviorSubject<Bool>(value: false)
    
    var currentPostId: String? {
        try? post.value().postID
    }
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let likeBtnTapped: Observable<Void>
        let ellipsisBtnTapped: Observable<Void>
        let followBtnTapped: Observable<Void>
        let commentPostBtnTapped: Observable<Void>
    }
    
    struct Output {
        let content: Driver<String>
        let nickname: Driver<String>
        let profileImageUrl: Driver<String?>
        let postImageUrl: Driver<String?>
        let likeStatus: Driver<Bool>
        let likeButtonImage: Driver<String>
        let ellipsisVisibility: Driver<Bool>
        let goReservationVisibility: Driver<Bool>
        let showActionSheet: Driver<Void>
        let formattedPrice: Driver<String>
        let imageUrls: Driver<[String]>
        let followState: Driver<Bool>
        let isFollowButtonHidden: Driver<Bool>
        let comments: Driver<[Comment]>
    }
    
    init(post: Post) {
        self.post = BehaviorSubject<Post>(value: post)
        
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
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

        let ellipsisVisibility = post
            .map { $0.creator.userID != userID }
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

        let formattedPrice = post.map { post in
            let price = post.content5?.formattedAsCurrency() ?? "가격 정보 없음"
            let product = post.content4 ?? "제품 정보 없음"
            return "\(product) \(price)"
        }.asDriver(onErrorJustReturn: "데이터 로드 실패")

        let imageUrls = post.map { $0.files }
            .asDriver(onErrorJustReturn: [])
        
        let myProfile = input.viewDidLoadTrigger
            .flatMapLatest { _ -> Observable<MyProfileModel> in
                NetworkManager.performRequest(route: Router.myProfile, dataType: MyProfileModel.self)
                    .asObservable()
            }
            .share(replay: 1, scope: .whileConnected)

        let initialFollowState = myProfile
            .withLatestFrom(post) { profile, post in
                profile.following.contains { $0.userID == post.creator.userID }
            }
            .do(onNext: { [weak self] isFollowing in
                self?.followingStatus.onNext(isFollowing)
            })

        let followStateChanges = input.followBtnTapped
            .withLatestFrom(followingStatus)
            .flatMapLatest { [weak self] isFollowing -> Observable<Bool> in
                guard let self = self else { return Observable.just(isFollowing) }
                let userID = try self.post.value().creator.userID
                let route = isFollowing ? Router.unfollowUser(userId: userID) : Router.followUser(userId: userID)
                return NetworkManager.performRequest(route: route, dataType: FollowModel.self)
                    .asObservable()
                    .map { $0.followingStatus }
                    .catchAndReturn(isFollowing)
            }
            .share(replay: 1, scope: .whileConnected)

        followStateChanges
            .subscribe(onNext: { [weak self] newState in
                self?.followingStatus.onNext(newState)
            })
            .disposed(by: disposeBag)

        let followState = Observable.merge(initialFollowState, followStateChanges)
            .asDriver(onErrorJustReturn: false)

        let isFollowButtonHidden = post
            .map { $0.creator.userID == userID }
            .asDriver(onErrorJustReturn: false)

        let comments = input.commentPostBtnTapped
            .flatMapLatest { [weak self] _ -> Observable<[Comment]> in
                guard let self = self, let postComments = try? self.post.value().comments else {
                    return .just([])
                }
                return .just(postComments)
            }
            .asDriver(onErrorJustReturn: [])

        return Output(
            content: content,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            postImageUrl: postImageUrl,
            likeStatus: likeStatus,
            likeButtonImage: likeButtonImage,
            ellipsisVisibility: ellipsisVisibility,
            goReservationVisibility: goReservationVisibility,
            showActionSheet: showActionSheet,
            formattedPrice: formattedPrice,
            imageUrls: imageUrls,
            followState: followState,
            isFollowButtonHidden: isFollowButtonHidden,
            comments: comments
        )
    }
    
    private func toggleLikeStatus(for postID: String, newStatus: Bool) -> Observable<Bool> {
        let query = LikeQuery(like_status: newStatus)
        return NetworkManager.performRequest(route: Router.likePost(postId: postID, query: query), dataType: LikeModel.self)
            .asObservable()
            .map { $0.likeStatus }
            .catch { [weak self] error -> Observable<Bool> in
                if let apiError = error as? APIError {
                    self?.errorMessage.accept(apiError.errorMessage)
                } else {
                    self?.errorMessage.accept("알 수 없는 오류가 발생했습니다.")
                }
                return .just(false)
            }
    }
    
    func confirmDeletion() {
        guard let postID = try? post.value().postID else { return }
        NetworkManager.performRequest(route: Router.deletePost(postId: postID))
            .asObservable()
            .map { _ in Void() }
            .catch { [weak self] error -> Observable<Void> in
                if let apiError = error as? APIError {
                    self?.errorMessage.accept(apiError.errorMessage)
                } else {
                    self?.errorMessage.accept("알 수 없는 오류가 발생했습니다.")
                }
                return .just(())
            }
            .subscribe(onNext: { [weak self] in
                self?.postDeleteSuccess.accept(())
            })
            .disposed(by: disposeBag)
    }
}
