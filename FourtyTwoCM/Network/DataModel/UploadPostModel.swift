//
//  PostModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import Foundation

// MARK: - UploadPostModel
struct UploadPostModel: Decodable {
    let postID, content, content1, content2: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes, likes2, hashTags, comments: [String]?

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case content, content1, content2, createdAt, creator, files, likes, likes2, hashTags, comments
    }
}

// MARK: - Creator
struct Creator: Codable {
    let userID, nick, profileImage: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}
