//
//  ChatRoomListModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation

// MARK: - ChatRoomListModel
struct ChatRoomListModel: Codable {
    let data: [ChatRoomModel]
}

// MARK: - ChatRoomModel
struct ChatRoomModel: Codable {
    let roomID, createdAt, updatedAt: String
    let participants: [Participant]
    let lastChat: LastChat?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}

// MARK: - LastChat
struct LastChat: Codable {
    let chatID, roomID, content, createdAt: String
    let sender: Sender
    let files: [String]?

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, sender, files
    }
}

// MARK: - Sender
struct Sender: Codable {
    let userID, nick: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
    }
}

// MARK: - Participant
struct Participant: Codable {
    let userID, nick: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}
