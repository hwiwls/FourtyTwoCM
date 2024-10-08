//
//  ChatRoom.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation
import RealmSwift

class ChatRoom: Object {
    @Persisted(primaryKey: true) var roomId: String
    @Persisted var participants: List<User>

    convenience init(roomId: String) {
        self.init()
        self.roomId = roomId
    }
}
