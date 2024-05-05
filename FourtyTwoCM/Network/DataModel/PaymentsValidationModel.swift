//
//  PaymentsValidationModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation

struct PaymentsValidationModel: Codable {
    let impUid, postID, productName: String?
    let price: Int?

    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
        case postID = "post_id"
        case productName, price
    }
}
