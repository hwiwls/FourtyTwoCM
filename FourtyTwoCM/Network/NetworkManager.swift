//
//  NetworkManager.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import Alamofire
import RxSwift

enum NetworkError: Error {
    case unauthorized // 로그인 401
}

struct NetworkManager {
    
    static func createLogin(query: SignInQuery) -> Single<SignInModel> {
        return Single<SignInModel>.create { single in
            do {
                let urlRequest = try Router.login(query: query).asURLRequest()
                                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: SignInModel.self) { response in
                        switch response.result {
                        case .success(let signInModel):
                            do {
                                try Keychain.shared.saveToken(kind: .accessToken, token: signInModel.accessToken)
                                print("AccessToken 저장 성공: \(signInModel.accessToken)")
                                try Keychain.shared.saveToken(kind: .refreshToken, token: signInModel.refreshToken)
                                print("RefreshToken 저장 성공: \(signInModel.refreshToken)")
                                
                                single(.success(signInModel))
                            } catch {
                                single(.failure(error))
                            }
                        case .failure(let error):
                            print("키체인 저장 오류: \(error)")
                            if response.response?.statusCode == 401 {
                                single(.failure(NetworkError.unauthorized))
                                return
                            }
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    
    static func createAccount(query: SignUpQuery) -> Single<SignUpModel> {
        return Single<SignUpModel>.create { single in
            do {
                let urlRequest = try Router.signUp(query: query).asURLRequest()
                                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: SignUpModel.self) { response in
                        switch response.result {
                        case .success(let signUpModel):
                            single(.success(signUpModel))
                        case .failure(let error):
                            single(.failure(error))
                            print("failure: \(error)")
                            if let response = response.response {
                                print("HTTP Status Code: \(response.statusCode)")
                            }
                        }
                    }
            } catch {
                single(.failure(error))
                print("URLRequest Error: \(error)")
            }
            
            return Disposables.create()
        }
    }
    
    static func requestEmailValid(query: EmailValidationQuery) -> Single<EmailValidationModel> {
        return Single<EmailValidationModel>.create { single in
            do {
                let urlRequest = try Router.emailValidation(query: query).asURLRequest()
                                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: EmailValidationModel.self) { response in
                        switch response.result {
                        case .success(let emailValidationModel):
                            print("requestEmailValid success: \(emailValidationModel)")
                            single(.success(emailValidationModel))
                        case .failure(let error):
                            print("requestEmailValid error: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func requestViewPost(query: ViewPostQuery) -> Single<FeedModel> {
        return Single<FeedModel>.create { single in
            do {
                let urlRequest = try Router.viewPost(query: query).asURLRequest()
                                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: FeedModel.self) { response in
                        switch response.result {
                        case .success(let feedModel):
                            print("feedModel success: \(feedModel)")
                            single(.success(feedModel))
                        case .failure(let error):
                            print("feed error: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
}
