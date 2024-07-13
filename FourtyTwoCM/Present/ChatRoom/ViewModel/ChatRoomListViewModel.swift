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
        let chatRoomClicked: Observable<IndexPath>
    }
    
    struct Output {
        let initialLoad: Driver<[ChatRoomModel]>
        let refreshLoad: Driver<[ChatRoomModel]>
        let errorMessage: Driver<String>
        let isRefreshing: Driver<Bool>
        let moveToChat: Driver<(String, String, String)>
    }
    
    func transform(input: Input) -> Output {
        let errorMessageRelay = PublishRelay<String>()
        let isRefreshingRelay = PublishRelay<Bool>()
        
        let chatRoomsRelay = BehaviorRelay<[ChatRoomModel]>(value: [])
        
        // Initial load
        let initialLoad = input.viewDidLoadTrigger
            .flatMapLatest {
                NetworkManager.performRequest(route: .getChatRoomList, dataType: ChatRoomListModel.self)
                    .asObservable()
                    .do(onNext: { response in
                        chatRoomsRelay.accept(response.data)
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
            .map { _ in chatRoomsRelay.value }
            .asDriver(onErrorJustReturn: [])
        
        // Refresh load
        let refreshLoad = input.refreshTrigger
            .do(onNext: { _ in isRefreshingRelay.accept(true) })
            .flatMapLatest {
                NetworkManager.performRequest(route: .getChatRoomList, dataType: ChatRoomListModel.self)
                    .asObservable()
                    .do(onNext: { response in
                        chatRoomsRelay.accept(response.data)
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
            .map { _ in chatRoomsRelay.value }
            .asDriver(onErrorJustReturn: [])
        
        let errorMessage = errorMessageRelay.asDriver(onErrorJustReturn: "알 수 없는 네트워크 오류")
        let isRefreshing = isRefreshingRelay.asDriver(onErrorJustReturn: false)
        
        let moveToChat = input.chatRoomClicked
            .withLatestFrom(chatRoomsRelay) { indexPath, chatRooms in
                let chatRoom = chatRooms[indexPath.row]
                let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
                let participant = chatRoom.participants.first { $0.userID != userId }
                let participantId = participant?.userID ?? ""
                let participantName = participant?.nick ?? ""
                return (chatRoom.roomID, participantId, participantName)
            }
            .asDriver(onErrorJustReturn: ("", "", ""))

        
        return Output(
            initialLoad: initialLoad,
            refreshLoad: refreshLoad,
            errorMessage: errorMessage,
            isRefreshing: isRefreshing,
            moveToChat: moveToChat
        )
    }
}
