//
//  Router.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import Alamofire

enum Router {
    case login(query: SignInQuery)
    case signUp(query: SignUpQuery)
    case emailValidation(query: EmailValidationQuery)
    case viewPost
}

extension Router: TargetType {
    var baseURL: String {
        BaseURL.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signUp:
            return .post
        case .emailValidation:
            return .post
        case .viewPost:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "users/login"
        case .signUp:
            return "users/join"
        case .emailValidation:
            return "validation/email"
        case .viewPost:
            return "posts"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .login:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            return [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .signUp:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            return [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .emailValidation:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            return [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .viewPost:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            return [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        }
    }
    
    var parameter: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .login(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)   
        case .signUp(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .emailValidation(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .viewPost:
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode("ker0r0")
        }
    }
}
