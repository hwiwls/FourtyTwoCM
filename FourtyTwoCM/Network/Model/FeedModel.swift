//
//  PostModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/22/24.
//

import Foundation

struct FeedModel: Decodable {
    let data: [Post]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct Post: Decodable {
    let postID, productID, content: String
    let createdAt: String
    let creator: PostCreator
    let files: [String]
    var likes, likes2, hashTags: [String]?
    let comments: [Comment]?
    let content1, content2: String  // 위도, 경도

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case productID = "product_id"
        case content, content1, createdAt, creator, files, likes, likes2, hashTags, comments, content2
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postID = try container.decode(String.self, forKey: .postID)
        self.productID = try container.decode(String.self, forKey: .productID)
        self.content = try container.decode(String.self, forKey: .content)
        self.content1 = try container.decode(String.self, forKey: .content1)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(PostCreator.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decodeIfPresent([String].self, forKey: .likes) ?? ["rr"]
        self.likes2 = try container.decodeIfPresent([String].self, forKey: .likes2) ?? []
        self.hashTags = try container.decodeIfPresent([String].self, forKey: .hashTags) ?? []
        self.comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? []
        self.content2 = try container.decode(String.self, forKey: .content2)
    }
    
    
    
}

// MARK: - Comment
struct Comment: Decodable {
    let commentID, content, createdAt: String
    let creator: CommentCreator

    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content, createdAt, creator
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentID = try container.decode(String.self, forKey: .commentID)
        self.content = try container.decode(String.self, forKey: .content)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(CommentCreator.self, forKey: .creator)
    }
}

// MARK: - CommentCreator
struct CommentCreator: Decodable {
    let userID, nick: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
    }
    
}

// MARK: - DatumCreator
struct PostCreator: Decodable {
    let userID, nick: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}
