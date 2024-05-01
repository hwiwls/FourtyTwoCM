//
//  PermissionViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class PermissionsViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
        let agreeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let showPermissionAlert: Observable<String>
        let navigateToTabBar: Observable<Void>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let permissions = Permissions.shared
        
        let enableButton = Observable.combineLatest(
            permissions.isLocationAuthorized,
            permissions.isCameraAuthorized,
            permissions.isPhotosAuthorized
        ) { $0 && $1 && $2 }
        .asDriver(onErrorJustReturn: false)
        
        let agreeButtonDebounced = input.agreeButtonTapped
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
        
        let showPermissionAlert = agreeButtonDebounced
            .withLatestFrom(enableButton)
            .filter { !$0 }
            .map { _ in "위치, 카메라 및 갤러리 접근 동의가 필요합니다" }
        
        let navigateToTabBar = agreeButtonDebounced
            .withLatestFrom(enableButton)
            .filter { $0 }
            .map { _ in Void() }
        
        return Output(
            showPermissionAlert: showPermissionAlert,
            navigateToTabBar: navigateToTabBar
        )
    }
}

