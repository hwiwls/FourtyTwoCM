//
//  SignInModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation

struct SignInModel: Decodable {
    let accessToken: String
    let refreshToken: String
}
