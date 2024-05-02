//
//  Router.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import Alamofire

enum Router {
    case login(query: SignInQuery)  // 로그인
    case signUp(query: SignUpQuery) // 회원가입
    case emailValidation(query: EmailValidationQuery)   // 이메일 중복 확인
    case viewPost(query: ViewPostQuery) // 게시물 조회
    case likePost(postId: String, query: LikeQuery) // 게시물 좋아요
    case deletePost(postId: String) // 게시물 삭제
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
        case .likePost:
            return .post
        case .deletePost:
            return .delete
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
        case .likePost(let postId, _):
            return "posts/\(postId)/like"
        case .deletePost(let postId):
            return "posts/\(postId)"
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
            
            var accessToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("Error retrieving access token: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .likePost:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            var accessToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("Error retrieving access token: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .deletePost:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            var accessToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("Error retrieving access token: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        }
    }
    
    var parameter: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .viewPost(let query):
            var items = [URLQueryItem(name: "product_id", value: query.product_id),
                         URLQueryItem(name: "limit", value: query.limit)]
            
            if let next = query.next {
                items.append(URLQueryItem(name: "next", value: next))
            }
            return items
        default:
            return nil
        }
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
        case .viewPost(_):
            return nil
        case .likePost(postId: _, query: let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .deletePost(postId: _):
            return nil
        }
    }
}
