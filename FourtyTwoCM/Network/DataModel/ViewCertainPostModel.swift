//
//  ViewCertainPostModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import Foundation

struct ViewCertainPostModel: Decodable {
    let postID, productID, content, content1: String
    let content2, createdAt: String
    let creator: Creator
    let files, likes, likes2, buyers: [String]
    let hashTags: [String]
    let comments: [Comment]

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case productID = "product_id"
        case content, content1, content2, createdAt, creator, files, likes, likes2, buyers, hashTags, comments
    }
}
