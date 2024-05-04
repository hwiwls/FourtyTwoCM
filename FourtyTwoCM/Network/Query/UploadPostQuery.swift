//
//  UploadPostQuery.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import Foundation

struct UploadPostQuery: Encodable {
    let content: String
    let content1: String
    let content2: String
    let files: [String]
    let product_id: String
}
