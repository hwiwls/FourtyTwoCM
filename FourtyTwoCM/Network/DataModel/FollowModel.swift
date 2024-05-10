//
//  FollowModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/10/24.
//

import Foundation

struct FollowModel: Codable {
    let nick, opponentNick: String
    let followingStatus: Bool

    enum CodingKeys: String, CodingKey {
        case nick
        case opponentNick = "opponent_nick"
        case followingStatus = "following_status"
    }
}
