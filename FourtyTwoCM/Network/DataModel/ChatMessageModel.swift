//
//  ChatMessageModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/14/24.
//

import Foundation

// MARK: - ChatMessageModel
struct ChatMessageModel: Decodable {
    let data: [ChatDetail]
}

// MARK: - ChatDetail
struct ChatDetail: Decodable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let sender: Sender
    let files: [String?]

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, sender, files
    }
}