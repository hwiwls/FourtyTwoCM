//
//  ChatSender.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation
import RealmSwift

class ChatSender: EmbeddedObject {
    @Persisted var userId: String
    @Persisted var nick: String
    @Persisted var profileImage: String?

    convenience init(userId: String, nick: String, profileImage: String? = nil) {
        self.init()
        self.userId = userId
        self.nick = nick
        self.profileImage = profileImage
    }
}
