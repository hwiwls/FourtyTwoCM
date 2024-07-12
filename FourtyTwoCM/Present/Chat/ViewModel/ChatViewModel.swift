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
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    
}
