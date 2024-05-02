//
//  NetworkManager.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import Alamofire
import RxSwift

struct NetworkManager {
    
    // 제네릭 API 호출 함수
    static func performRequest<T: Decodable>(route: Router, dataType: T.Type) -> Single<T> {
        return Single<T>.create { single in
            do {
                let urlRequest = try route.asURLRequest()
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: dataType) { response in
                        switch response.result {
                        case .success(let data):
                            single(.success(data))
                        case .failure(_):
                            if let statusCode = response.response?.statusCode {
                                single(.failure(APIError.mapError(from: statusCode)))
                            } else {
                                single(.failure(APIError.unknown))
                            }
                        }
                    }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    static func requestDeletePost(postID: String) -> Single<Void> {
        return Single<Void>.create { single in
            do {
                let urlRequest = try Router.deletePost(postId: postID).asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .response { response in
                        switch response.result {
                        case .success:
                            print("Delete post success")
                            single(.success(()))
                        case .failure(let error):
                            print("Delete post error: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create {
                // 요청 취소 처리
            }
        }
    }

    
   
}
