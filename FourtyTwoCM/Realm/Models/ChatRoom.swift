//
//  ChatRoom.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation
import RealmSwift

class ChatRoom: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var roomId: String
    @Persisted var createdAt: Date
    @Persisted var participants: List<ChatParticipant>

    convenience init(roomId: String, createdAt: Date) {
        self.init()
        self.roomId = roomId
        self.createdAt = createdAt
    }
}

