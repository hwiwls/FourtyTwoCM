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
    @Persisted var participants: List<ChatParticipant>

    convenience init(roomId: String) {
        self.init()
        self.roomId = roomId
    }
}

