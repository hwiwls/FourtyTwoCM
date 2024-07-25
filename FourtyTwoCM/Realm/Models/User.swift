//
//  User.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/22/24.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var userId: String
    @Persisted var nick: String

    convenience init(userId: String, nick: String) {
        self.init()
        self.userId = userId
        self.nick = nick
    }
}
