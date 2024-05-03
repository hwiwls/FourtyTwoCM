//
//  Interceptor.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/3/24.
//

import Foundation
import Alamofire

class APIInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        var accessToken: String = ""
        
        do {
            accessToken = try Keychain.shared.getToken(kind: .accessToken)
            print("인터셉터 파일에서 액세스토큰을 가져옴: \(accessToken)")
        } catch {
            print("인터셉터 파일에서 액세스토큰을 가지고 오지 못함: \(error)")
        }
        
        if accessToken == "" {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        
        urlRequest.setValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        do {
            let urlRequest = try Router.refresh.asURLRequest()
            
            AF.request(urlRequest).responseDecodable(of: RefreshModel.self) { response in
                
                guard let responseData = response.response else { return }
                let statusCode = responseData.statusCode
                
                switch response.result {
                    
                case .success(let data):
                    do {
                        try Keychain.shared.saveToken(kind: .accessToken, token: data.accessToken)
                    } catch {
                        print("토큰 저장 실패: \(error)")
                    }
                    
                    completion(.retry)
                    
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.Name("TokenRefreshFailed"), object: nil)
                    completion(.doNotRetryWithError(error))
                }
            }
        } catch {
            completion(.doNotRetryWithError(error))
        }
        
    }
}

