//
//  NetworkError.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/2/24.
//

import Foundation

enum APIError: Error {
    case wrongAccess(String)
    case unauthorized(String)
    case expiredToken(String)
    case forbidden(String)
    case notFound(String)
    case conflict(String)
    case serverError(String)
    case clientError(String)
    case unknown(String)
    case userNotParticipant(String)
    case userOrChatRoomNotFound(String)

    static func mapError(from response: HTTPURLResponse, data: Data?) -> APIError {
        let message = (try? JSONDecoder().decode(ErrorResponse.self, from: data ?? Data()))?.message ?? "알 수 없는 오류가 발생했습니다."
        switch response.statusCode {
        case 400:
        return .wrongAccess(message)
        case 401:
            return .unauthorized(message)
        case 403:
            return .forbidden(message)
        case 404:
            return .notFound(message)
        case 409:
            return .conflict(message)
        case 410:
            return .userOrChatRoomNotFound(message)
        case 419:
            return .expiredToken(message)
        case 445:
            return .userNotParticipant(message)
        case 500...599:
            return .serverError(message)
        default:
            return .unknown(message)
        }
    }

    var errorMessage: String {
        switch self {
        case .unauthorized(let message),
                .expiredToken(let message),
                .forbidden(let message),
                .notFound(let message),
                .conflict(let message),
                .serverError(let message),
                .clientError(let message),
                .wrongAccess(let message),
                .userNotParticipant(let message),
                .userOrChatRoomNotFound(let message),
                .unknown(let message):
            return message
        }
    } 
}

// 서버 응답에서 사용할 메시지 포맷
struct ErrorResponse: Decodable {
    let message: String
}
