//
//  PaymentsValidationQuery.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation

struct PaymentsValidationQuery: Encodable {
    let imp_uid: String
    let post_id: String
    let productName: String
    let price: Int
}
