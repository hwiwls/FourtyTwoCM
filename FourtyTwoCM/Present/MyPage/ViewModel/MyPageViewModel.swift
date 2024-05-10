//
//  MyPageViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation
import RxSwift
import RxCocoa

class MyPageViewModel: ViewModelType {
    struct Input {
        let loadProfileTrigger: Observable<Void>
    }
    
    struct Output {
        let profileImageURL: Driver<URL?>
        let username: Driver<String>
        let followerCount: Driver<String>
        let followingCount: Driver<String>
        let error: Driver<Error>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let errorTracker = PublishSubject<Error>()
        let profileData = input.loadProfileTrigger
            .flatMapLatest {
                NetworkManager.performRequest(route: Router.myProfile, dataType: MyProfileModel.self)
                    .asObservable()
                    .catch { error -> Observable<MyProfileModel> in
                        errorTracker.onNext(error)
                        return Observable.empty()
                    }
            }
            .share(replay: 1, scope: .whileConnected)
        
        let profileImageURL = profileData
            .map { profile in URL(string: profile.profileImage ?? "") }
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
        
        let errorDriver = errorTracker
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            profileImageURL: profileImageURL,
            username: username,
            followerCount: followerCount,
            followingCount: followingCount,
            error: errorDriver
        )
    }
}
