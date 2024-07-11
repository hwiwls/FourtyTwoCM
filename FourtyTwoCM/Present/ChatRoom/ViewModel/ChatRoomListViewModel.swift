//
//  ChattingViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatRoomListViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let refreshTrigger: Observable<Void>
    }
    
    struct Output {
        let initialLoad: Driver<[ChatRoomModel]>
        let refreshLoad: Driver<[ChatRoomModel]>
        let errorMessage: Driver<String>
        let isRefreshing: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let errorMessageRelay = PublishRelay<String>()
        let isRefreshingRelay = PublishRelay<Bool>()
        
        // Initial load
        let initialLoad = input.viewDidLoadTrigger
            .flatMapLatest {
                NetworkManager.performRequest(route: .getChatRoomList, dataType: ChatRoomListModel.self)
                    .asObservable()
                    .catch { error in
                        if let apiError = error as? APIError {
                            errorMessageRelay.accept(apiError.errorMessage)
                        } else {
                            errorMessageRelay.accept("알 수 없는 네트워크 오류")
                        }
                        return .empty()
                    }
            }
            .map { $0.data }
            .asDriver(onErrorJustReturn: [])
        
        // Refresh load
        let refreshLoad = input.refreshTrigger
            .do(onNext: { _ in isRefreshingRelay.accept(true) })
            .flatMapLatest {
                NetworkManager.performRequest(route: .getChatRoomList, dataType: ChatRoomListModel.self)
                    .asObservable()
                    .do(onNext: { response in
                        print("Server response: \(response.data)") // 서버 응답 출력
                    })
                    .catch { error in
                        if let apiError = error as? APIError {
                            errorMessageRelay.accept(apiError.errorMessage)
                        } else {
                            errorMessageRelay.accept("알 수 없는 네트워크 오류")
                        }
                        return .empty()
                    }
            }
            .do(onNext: { _ in isRefreshingRelay.accept(false) })
            .map { $0.data }
            .asDriver(onErrorJustReturn: [])
        
        let errorMessage = errorMessageRelay.asDriver(onErrorJustReturn: "알 수 없는 네트워크 오류")
        let isRefreshing = isRefreshingRelay.asDriver(onErrorJustReturn: false)
        
        return Output(initialLoad: initialLoad, refreshLoad: refreshLoad, errorMessage: errorMessage, isRefreshing: isRefreshing)
    }
}
