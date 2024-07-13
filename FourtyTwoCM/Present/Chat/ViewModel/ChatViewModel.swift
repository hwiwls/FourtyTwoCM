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
    }
    
    func transform(input: Input) -> Output {
        let messagesRelay = BehaviorRelay(value: [ChatMessage]())
                
        input.loadMessage
            .map { [weak self] _ -> [ChatMessage] in
                guard let self = self else { return [] }
                let messages = self.chatRepository.fetchMessagesUsingRoomId(for: self.participantId)
                return messages
            }
            .bind(to: messagesRelay)
            .disposed(by: disposeBag)
        
        return Output(messages: messagesRelay.asDriver())
    }
}
