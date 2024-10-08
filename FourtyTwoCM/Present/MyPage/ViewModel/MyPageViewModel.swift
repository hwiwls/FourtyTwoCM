//
//  MyPageViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    struct Input {
        let loadProfileTrigger: Observable<Void>
    }
    
    struct Output {
        let profileImageURL: Driver<URL?>
        let username: Driver<String>
        let followerCount: Driver<String>
        let followingCount: Driver<String>
        let error: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = PublishRelay<String>()
        
        let profileData = input.loadProfileTrigger
            .flatMapLatest {
                NetworkManager.performRequest(route: Router.myProfile, dataType: MyProfileModel.self)
                    .asObservable()
                    .catch { error -> Observable<MyProfileModel> in
                        let errorMessage = (error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다."
                        errorTracker.accept(errorMessage)
                        return Observable.empty()
                    }
            }
            .share(replay: 1, scope: .whileConnected)
        
        let profileImageURL = profileData
            .map { URL(string: $0.profileImage ?? "") }
            .asDriver(onErrorJustReturn: nil)
        
        let username = profileData
            .map { $0.nick }
            .asDriver(onErrorJustReturn: "Unknown")
        
        let followerCount = profileData
            .map { "\($0.followers.count) followers" }
            .asDriver(onErrorJustReturn: "0 followers")
        
        let followingCount = profileData
            .map { "\($0.following.count) followings" }
            .asDriver(onErrorJustReturn: "0 followings")
        
        let errorDriver = errorTracker.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        
        return Output(
            profileImageURL: profileImageURL,
            username: username,
            followerCount: followerCount,
            followingCount: followingCount,
            error: errorDriver
        )
    }
}
