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
    case viewCertainPost(postId: String)
    case viewMyPosts(userID: String, query: ViewMyPostsQuery)
    case viewMyLikes(query: ViewMyLikesQuery)
    case getChatRoomList
    case getChatHistory(roomId: String, query: ChatHistoryQuery)
    case sendMessage(roomId: String)
}

extension Router: TargetType {
    var baseURL: String {
        BaseURL.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .viewPost, .refresh, .myProfile, .viewCertainPost, .viewMyPosts, .viewMyLikes, .getChatRoomList, .getChatHistory:
            return .get
        case .deletePost, .unfollowUser:
            return .delete
        case .login, .signUp, .emailValidation, .likePost, .uploadFile, .uploadPost, .paymentValidation, .followUser, .writeComment, .sendMessage:
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
        case .unfollowUser(let userId):
            return "follow/\(userId)"
        case .writeComment(let postId, query: _):
            return "posts/\(postId)/comments"
        case .viewCertainPost(let postId):
            return "posts/\(postId)"
        case .viewMyPosts(let userID, _):
            return "posts/users/\(userID)"
        case .viewMyLikes:
            return "posts/likes/me"
        case .getChatRoomList:
            return "chats"
        case .getChatHistory(let roomId, query: _):
            return "chats/\(roomId)"
        case .sendMessage(let roomId):
            return "chats/\(roomId)"
        }
    }
    
    var header: [String : String] {
        guard let sesacKey = Bundle.main.sesacKey else {
            print("sesacKey를 로드하지 못했습니다.")
            return [:]
        }
        
        func getAccessToken() -> String {
            do {
                return try Keychain.shared.getToken(kind: .accessToken)
            } catch {
                print("Error retrieving access token: \(error)")
                return ""
            }
        }
        
        func getRefreshToken() -> String {
            do {
                return try Keychain.shared.getToken(kind: .refreshToken)
            } catch {
                print("Error retrieving refresh token: \(error)")
                return ""
            }
        }
        
        switch self {
        case .login, .signUp, .emailValidation:
            return [
                HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .uploadFile:
            let accessToken = getAccessToken()
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.contentType.rawValue: HTTPHeader.multipart.rawValue,
                HTTPHeader.sesacKey.rawValue: sesacKey
            ]
        case .refresh:
            let accessToken = getAccessToken()
            let refreshToken = getRefreshToken()
            return [
                HTTPHeader.authorization.rawValue: accessToken,
                HTTPHeader.sesacKey.rawValue: sesacKey,
                HTTPHeader.refresh.rawValue: refreshToken
            ]
        default:
            let accessToken = getAccessToken()
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
            
        case .viewMyPosts(_, let query):
            var items = [
                URLQueryItem(name: "product_id", value: query.product_id),
                URLQueryItem(name: "limit", value: query.limit)
            ]
            if let next = query.next {
                items.append(URLQueryItem(name: "next", value: next))
            }
            return items
        case .viewMyLikes(let query):
            var items = [
                URLQueryItem(name: "limit", value: query.limit)
            ]
            if let next = query.next {
                items.append(URLQueryItem(name: "next", value: next))
            }
            return items
            
        case .getChatHistory(_, let query):
            var items = [URLQueryItem]()
            if let cursorDate = query.cursor_date {
                items.append(URLQueryItem(name: "cursor_date", value: cursorDate))
            }
            return items
        default:
            return nil
        }
    }
    
    
    var body: Data? {
        func encodeQuery<T: Encodable>(_ query: T) -> Data? {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        }

        switch self {
        case .login(let query):
            return encodeQuery(query)
        case .signUp(let query):
            return encodeQuery(query)
        case .emailValidation(let query):
            return encodeQuery(query)
        case .likePost(postId: _, query: let query):
            return encodeQuery(query)
        case .uploadPost(let query):
            return encodeQuery(query)
        case .paymentValidation(query: let query):
            return encodeQuery(query)
        case .writeComment(postId: _, query: let query):
            return encodeQuery(query)
        case .sendMessage(let query):
            return encodeQuery(query)
        default:
            return nil
        }
    }
}
