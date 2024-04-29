//
//  LikeModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/25/24.
//

import Foundation

struct LikeModel: Decodable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}
