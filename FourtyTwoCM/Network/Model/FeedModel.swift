//
//  PostModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/22/24.
//

import Foundation

struct FeedModel: Decodable {
    let data: [Post]
}

struct Post: Decodable {
    let postID, productID, title, content: String
    let content1, createdAt: String
    let creator: PostCreator
    let files, likes, likes2, hashTags: [String]
    let comments: [Comment]
    /*
     content2: 위도
     content3: 경도
     
     */
    let content2, content3, content4, content5: String?

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case productID = "product_id"
        case title, content, content1, createdAt, creator, files, likes, likes2, hashTags, comments, content2, content3, content4, content5
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postID = try container.decode(String.self, forKey: .postID)
        self.productID = try container.decode(String.self, forKey: .productID)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.content1 = try container.decode(String.self, forKey: .content1)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(PostCreator.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.likes2 = try container.decode([String].self, forKey: .likes2)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.comments = try container.decode([Comment].self, forKey: .comments)
        self.content2 = try container.decodeIfPresent(String.self, forKey: .content2) ?? "ㅜㅜ"
        self.content3 = try container.decodeIfPresent(String.self, forKey: .content3) ?? "ㅜㅜ"
        self.content4 = try container.decodeIfPresent(String.self, forKey: .content4) ?? "ㅜㅜ"
        self.content5 = try container.decodeIfPresent(String.self, forKey: .content5) ?? "ㅜㅜ"
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
