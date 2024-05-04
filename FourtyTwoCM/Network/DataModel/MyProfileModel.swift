//
//  MyProfileModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation

// MARK: - MyProfileModel
struct MyProfileModel: Decodable {
    let userID, email, nick, profileImage: String
    let followers, following, posts: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, profileImage, followers, following, posts
    }
}
