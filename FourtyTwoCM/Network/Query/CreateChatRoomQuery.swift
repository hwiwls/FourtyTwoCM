//
//  CreateChatRoomQuery.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/18/24.
//

import Foundation

struct CreateChatRoomQuery: Encodable {
    let opponentId: String
    
    enum CodingKeys: String, CodingKey {
        case opponentId = "opponent_id"
    }
}
