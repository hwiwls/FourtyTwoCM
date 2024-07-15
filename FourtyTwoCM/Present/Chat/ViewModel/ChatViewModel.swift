//
//  ChatViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/12/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    let chatRepository = ChatRepository()
    
    let participantId: String
    let participantNick: String
    
    init(participantId: String, participantNick: String) {
        self.participantId = participantId
        self.participantNick = participantNick
    }
    
    struct Input {
        let loadMessage: Observable<Void>
    }
    
    struct Output {
        let messages: Driver<[ChatMessage]>
        let error: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let messagesRelay = BehaviorRelay(value: [ChatMessage]())
        let errorRelay = PublishRelay<String>()
        
        input.loadMessage
            .flatMapLatest { [weak self] _ -> Observable<[ChatMessage]> in
                guard let self = self else { return .just([]) }
                
                if self.chatRepository.isChatRoomExists(with: self.participantId) {
                    guard let roomId = self.chatRepository.fetchChatRoomId(with: self.participantId) else {
                        return .just([])
                    }
                    return self.updateAndFetchMessages(roomId: roomId)
                        .catch { error in
                            self.handleError(error, errorRelay: errorRelay)
                            return .just([])
                        }
                        .asObservable()
                } else {
                    return NetworkManager.performRequest(route: .getChatRoomList, dataType: ChatRoomListModel.self)
                        .asObservable()
                        .map { $0.data }
                        .do(onNext: { chatRoomList in
                            chatRoomList.forEach { self.chatRepository.saveChatRoom($0) }
                        })
                        .flatMap { chatRoomList -> Single<[ChatMessage]> in
                            guard let chatRoom = chatRoomList.first(where: { $0.participants.contains(where: { $0.userID == self.participantId }) }) else {
                                return .just([])
                            }
                            
                            return self.updateAndFetchMessages(roomId: chatRoom.roomID)
                        }
                        .catch { error in
                            self.handleError(error, errorRelay: errorRelay)
                            return .just([])
                        }
                        .asObservable()
                }
            }
            .bind(to: messagesRelay)
            .disposed(by: disposeBag)
        
        return Output(
            messages: messagesRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
    
    private func updateAndFetchMessages(roomId: String) -> Single<[ChatMessage]> {
        let lastMessageDate = chatRepository.fetchLastMessageTimestamp(for: roomId)
        let cursorDate = lastMessageDate?.toISO8601String()
        let query = ChatHistoryQuery(cursor_date: cursorDate)
        
        return NetworkManager.performRequest(route: .getChatHistory(roomId: roomId, query: query), dataType: ChatMessageModel.self)
            .map { $0.data }
            .do(onSuccess: { chatDetails in
                self.chatRepository.saveMessages(chatDetails)
            })
            .flatMap { _ in
                Single.just(self.chatRepository.fetchMessages(for: roomId))
            }
    }
    
    private func handleError(_ error: Error, errorRelay: PublishRelay<String>) {
        if let apiError = error as? APIError {
            errorRelay.accept(apiError.errorMessage)
        } else {
            errorRelay.accept("알 수 없는 오류가 발생했습니다.")
        }
    }
}
