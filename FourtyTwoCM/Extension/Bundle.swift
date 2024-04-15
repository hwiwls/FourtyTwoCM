//
//  Bundle.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation

extension Bundle {
    var sesacKey: String? {
        return infoDictionary?["SesacKey"] as? String
    }
}
