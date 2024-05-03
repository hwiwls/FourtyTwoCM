//
//  NetworkError.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/2/24.
//

enum APIError: Error {
    case unauthorized
    case serverError
    case forbidden
    case notFound
    case unknown
    case expiredToken

    static func mapError(from statusCode: Int) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 410:
            return .notFound
        case 500..<600:
            return .serverError
        default:
            return .unknown
        }
    }
    
    func checkAccessTokenError() -> Bool {
        
        switch self {
        case .expiredToken:
            return true
        default:
            return false
        }
    }
}

