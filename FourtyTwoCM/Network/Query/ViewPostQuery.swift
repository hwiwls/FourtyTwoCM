//
//  ViewPostQuery.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/23/24.
//

import Foundation

struct ViewPostQuery: Encodable {
    let product_id: String
    var next_cursor: String? 
}
