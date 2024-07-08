//
//  s.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/3/24.
//

import Foundation

extension String {
    func prependBaseURL() -> String {
        return BaseURL.baseURL.rawValue + "/" + self
    }
}
