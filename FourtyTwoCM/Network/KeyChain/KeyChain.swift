//
//  KeyChain.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Security
import Foundation

enum KeyChainError: Error {
    case noData
    case unexpectedData
    case unhandledError(status: OSStatus)
    case stringConversionFailed
    case tokenDataCreationFailed
}

class Keychain {
    static let shared = Keychain()

    enum TokenKind: String {
        case accessToken = "Authorization"  // 키체인 식별자
        case refreshToken = "RefreshToken"  // 키체인 식별자
    }

    private init() { }

    func saveToken(kind: TokenKind, token: String) throws {
        guard let data = token.data(using: .utf8) else { throw KeyChainError.tokenDataCreationFailed }

        let query = createQuery(kind: kind, data: data)
        
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)

        if status == errSecItemNotFound {
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeyChainError.unhandledError(status: addStatus) }
        } else if status != errSecSuccess {
            throw KeyChainError.unhandledError(status: status)
        }
    }

    func getToken(kind: TokenKind) throws -> String {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : kind.rawValue,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status != errSecItemNotFound else { throw KeyChainError.noData }
        guard status == errSecSuccess else { throw KeyChainError.unhandledError(status: status) }
        
        guard let data = dataTypeRef as? Data, let token = String(data: data, encoding: .utf8) else {
            throw KeyChainError.unexpectedData
        }
        
        return token
    }
    
    func deleteToken(kind: TokenKind) throws {
        let query = createQuery(kind: kind)
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeyChainError.unhandledError(status: status) }
    }

    private func createQuery(kind: TokenKind, data: Data? = nil) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : kind.rawValue
        ]

        if let data = data {
            query[kSecValueData as String] = data
        }

        return query
    }
}
