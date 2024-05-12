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
                AF.request(urlRequest, interceptor: APIInterceptor())
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: dataType) { response in
                        switch response.result {
                        case .success(let data):
                            print("performRequest success: \(dataType)")
                            single(.success(data))
                        case .failure(_):
                            if let statusCode = response.response?.statusCode, let data = response.data {
                                                            single(.failure(APIError.mapError(from: response.response!, data: data)))
                                                        } else {
                                                            single(.failure(APIError.unknown("네트워크 오류")))
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
                
                AF.request(urlRequest, interceptor: APIInterceptor())
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
    
     // 파일 업로드
    static func performMultipartRequest(route: Router) -> Single<FileModel> {
        return Single.create { single in
            do {
                let urlRequest = try route.asURLRequest()
                AF.upload(multipartFormData: { multipartFormData in
                    switch route {
                    case .uploadFile(let imageData):
                        multipartFormData.append(imageData.files, withName: "files", fileName: "fourtytwo.png", mimeType: "image/png")
                    default:
                        break
                    }
                }, with: urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: FileModel.self) { response in
                    switch response.result {
                    case .success(let data):
                               print("Decodable success: \(data)")
                               single(.success(data))
                           case .failure(let error):
                        if let httpResponse = response.response, let data = response.data {
                                                        single(.failure(APIError.mapError(from: httpResponse, data: data)))
                                                    } else {
                                                        // 여기서는 응답이 없거나 데이터가 없는 경우 처리
                                                        single(.failure(APIError.unknown("네트워크 오류 또는 데이터 누락")))
                                                    }
                           }
                }
            } catch {
                single(.failure(APIError.unknown("요청 생성 실패: \(error.localizedDescription)")))
            }
            return Disposables.create()
        }
    }
    
    
    
}
