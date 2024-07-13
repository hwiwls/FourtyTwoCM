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
    
    let chatRoomId: String?
    let participantId: String?
    let participantNick: String?
    
    init(chatRoomId: String?, participantId: String?, participantNick: String?) {
        self.chatRoomId = chatRoomId
        self.participantId = participantId
        self.participantNick = participantNick
        
        print("chatRoomId \(String(describing: chatRoomId))")
        print("participantId \(String(describing: participantId))")
        print("participantNick \(String(describing: participantNick))")
    }
    
    struct Input {
        let loadMessage: Observable<Void>
    }
    
    struct Output {
        let messages: Driver<[DummyMessage]>
    }
    
    func transform(input: Input) -> Output {
        let messagesRelay = BehaviorRelay(value: [DummyMessage]())

        
        input.loadMessage
            .map { _ in
                // 더미 메시지 로드
                return [
                    DummyMessage(senderID: "friend", text: "Hello, World!"),
                    DummyMessage(senderID: "6675009f488eb4cb431c9242", text: "Hello, World! Hello, World! Hello, World! \n Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World! Hello, World!"),
                    DummyMessage(senderID: "friend", text: "こんにちは、世界!"),
                    DummyMessage(senderID: "6675009f488eb4cb431c9242", text: "안녕하세요, 세상!")
                ]
            }
            .bind(to: messagesRelay)
            .disposed(by: disposeBag)
        
        return Output(messages: messagesRelay.asDriver())
    }
    
    
}
