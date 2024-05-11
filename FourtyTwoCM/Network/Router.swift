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
    case refresh // 토큰 갱신
    case uploadFile(query: UploadImageQuery) // 파일 업로드
    case uploadPost(query: UploadPostQuery)
    case myProfile
    case paymentValidation(query: PaymentsValidationQuery)
    case followUser(userId: String)
    case unfollowUser(userId: String)
    case writeComment(postId: String, query: WriteCommentQuery)
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
        case .refresh:
            return .get
        case .uploadFile:
            return .post
        case .uploadPost:
            return .post
        case .myProfile:
            return .get
        case .paymentValidation:
            return .post
        case .followUser:
            return .post
        case .unfollowUser:
            return .delete
        case .writeComment:
            return .post
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
        case .refresh:
            return "auth/refresh"
        case .uploadFile:
            return "posts/files"
        case .uploadPost:
            return "posts"
        case .myProfile:
            return "users/me/profile"
        case .paymentValidation:
            return "payments/validation"
        case .followUser(let userId):
            return "follow/\(userId)"
        case .unfollowUser(userId: let userId):
            return "follow/\(userId)"
        case .writeComment(postId: let postId, query: let query):
            return "posts/\(postId)/comments"
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
                print("게시글 좋아요에서 액세스 토큰을 가지고 오지 못함: \(error)")
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
                print("게시글 삭제에서 액세스 토큰을 가지고 오지 못함: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .refresh:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            var accessToken: String = ""
            var refreshToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("리프레시에서 액세스 토큰을 가지고 오지 못함: \(error)")
            }
            
            do {
                refreshToken = try Keychain.shared.getToken(kind: .refreshToken)
            } catch {
                print("리프레스에서 리프레시 토큰을 가지고 오지 못함: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.sesacKey.rawValue: sesacKey,
                HTTPHeader.refresh.rawValue: refreshToken
            ]
        case .uploadFile:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            var accessToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("파일 업로드에서 액세스 토큰을 가지고 오지 못함: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.multipart.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .uploadPost:
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            var accessToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("파일 업로드에서 액세스 토큰을 가지고 오지 못함: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .myProfile:
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
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .paymentValidation:
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
                HTTPHeader.sesacKey.rawValue: sesacKey,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue
            ]
        case .followUser:
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
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .unfollowUser:
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
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .writeComment(postId: let postId, query: let query):
            guard let sesacKey = Bundle.main.sesacKey else {
                print("sesacKey를 로드하지 못했습니다.")
                return [:]
            }
            
            print("sesacKey: \(sesacKey)")
            
            var accessToken: String = ""
            
            do {
                accessToken = try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("writeCommen에서 액세스 토큰을 가지고 오지 못함: \(error)")
            }
            
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        }
    }
    
    var parameter: String? {
        nil
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
        case .viewPost:
            return nil
        case .likePost(postId: _, query: let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .deletePost(postId: _):
            return nil
        case .refresh:
            return nil
        case .uploadFile:
            return nil
        case .uploadPost(let query):
            let encoder = JSONEncoder()
            return try? encoder.encode(query)
        case .myProfile:
            return nil
        case .paymentValidation(query: let query):
            let encoder = JSONEncoder()
            return try? encoder.encode(query)
        case .followUser:
            return nil
        case .unfollowUser:
            return nil
        case .writeComment(postId: let postId, query: let query):
            let encoder = JSONEncoder()
            return try? encoder.encode(query)
        }
    }
}
