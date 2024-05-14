//
//  ViewMyPostsQuery.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/13/24.
//

import Foundation

struct ViewMyPostsQuery: Encodable {
    let product_id: String
    var next: String?
    var limit: String
}
