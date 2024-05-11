//
//  CommentModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import Foundation

struct Commentmodel: Decodable {
    let commentID, content, createdAt: String
    let creator: CommentCreator

    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content, createdAt, creator
    }
}

