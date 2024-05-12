//
//  NetworkError.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/2/24.
//

//enum APIError: Error {
//    case unauthorized
//    case serverError
//    case forbidden
//    case notFound
//    case unsupportedFileType
//    case databaseError
//    case unknown
//    case expiredToken
//
//    static func mapError(from statusCode: Int) -> APIError {
//        switch statusCode {
//        case 400:
//            return .unsupportedFileType
//        case 401:
//            return .unauthorized
//        case 403:
//            return .forbidden
//        case 410:
//            return .databaseError
//        case 500..<600:
//            return .serverError
//        default:
//            return .unknown
//        }
//    }
//    
//    var errorMessage: String {
//        switch self {
//        case .unauthorized:
//            return "인증 오류가 발생했습니다. 로그인 정보를 확인해주세요."
//        case .serverError:
//            return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
//        case .forbidden:
//            return "접근이 금지되었습니다."
//        case .notFound:
//            return "요청하신 내용을 찾을 수 없습니다."
//        case .unsupportedFileType:
//            return "지원하지 않는 파일 형식입니다."
//        case .databaseError:
//            return "서버 DB 오류가 발생했습니다."
//        case .unknown:
//            return "알 수 없는 오류가 발생했습니다."
//        case .expiredToken:
//            return "로그인 정보가 만료되었습니다. 다시 로그인해주세요."
//        }
//    }
//    
//    func checkAccessTokenError() -> Bool {
//            
//            switch self {
//            case .expiredToken:
//                return true
//            default:
//                return false
//            }
//        }
//}

import Foundation

enum APIError: Error {
    case unauthorized(String)
    case expiredToken(String)
    case forbidden(String)
    case notFound(String)
    case conflict(String)
    case serverError(String)
    case clientError(String)
    case unknown(String)

    static func mapError(from response: HTTPURLResponse, data: Data?) -> APIError {
        let message = (try? JSONDecoder().decode(ErrorResponse.self, from: data ?? Data()))?.message ?? "알 수 없는 오류가 발생했습니다."
        switch response.statusCode {
        case 401:
            if message == "Token has expired" {
                return .expiredToken(message)
            }
            return .unauthorized(message)
        case 403:
            return .forbidden(message)
        case 404:
            return .notFound(message)
        case 409:
            return .conflict(message)
        case 400...499:
            return .clientError(message)
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
                .unknown(let message):
            return message
        }
    }
    
    
}

// 서버 응답에서 사용할 메시지 포맷
struct ErrorResponse: Decodable {
    let message: String
}
