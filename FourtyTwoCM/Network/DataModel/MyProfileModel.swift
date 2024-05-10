//
//  MyProfileModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation

// MARK: - MyProfileModel
struct MyProfileModel: Codable {
    let userID, email, nick: String
    let profileImage: String?
    let followers, following: [Follow]
    let posts: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, profileImage, followers, following, posts
    }
}

// MARK: - Follower
struct Follow: Codable {
    let userID, nick: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}

