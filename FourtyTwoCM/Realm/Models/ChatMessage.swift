//
//  ChatMessage.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation
import RealmSwift

class ChatMessage: Object {
    @Persisted(primaryKey: true) var chatId: String
    @Persisted var roomId: String
    @Persisted var content: String
    @Persisted var createdAt: Date
    @Persisted var sender: User?

    convenience init(chatId: String, roomId: String, content: String, createdAt: Date, sender: User?) {
        self.init()
        self.chatId = chatId
        self.roomId = roomId
        self.content = content
        self.createdAt = createdAt
        self.sender = sender
    }
}

