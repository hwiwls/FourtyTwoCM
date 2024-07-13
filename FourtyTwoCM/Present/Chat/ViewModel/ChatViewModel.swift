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
    
    let chatRoomId: String?
    let participantId: String
    let participantNick: String
    
    init(chatRoomId: String?, participantId: String, participantNick: String) {
        self.chatRoomId = chatRoomId
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
                
                guard let roomId = self.chatRepository.fetchChatRoomId(with: self.participantId) else {
                    return .just([])
                }
                
                return self.chatRepository.updateChatHistory(roomId: roomId)
                    .asObservable()
                    .catch { error in
                        if let apiError = error as? APIError {
                            errorRelay.accept(apiError.errorMessage)
                        } else {
                            errorRelay.accept("알 수 없는 오류가 발생했습니다.")
                        }
                        return .just([])
                    }
                    .flatMap { _ -> Observable<[ChatMessage]> in
                        return .just(self.chatRepository.fetchMessagesUsingRoomId(for: self.participantId))
                    }
            }
            .bind(to: messagesRelay)
            .disposed(by: disposeBag)
        
        return Output(
            messages: messagesRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
}
