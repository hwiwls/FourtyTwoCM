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
                            if let data = response.data {
                                single(.failure(APIError.mapError(from: response.response!, data: data)))
                            } else {
                                single(.failure(APIError.unknown("알 수 없는 네트워크 오류")))
                            }
                        }
                    }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    
    // 빈 응답을 처리하는 API 호출 함수
    static func performRequest(route: Router) -> Single<Void> {
        return Single<Void>.create { single in
            do {
                let urlRequest = try route.asURLRequest()
                AF.request(urlRequest, interceptor: APIInterceptor())
                    .validate(statusCode: 200..<300)
                    .response { response in
                        switch response.result {
                        case .success:
                            print("performRequest success: Void")
                            single(.success(()))
                        case .failure(_):
                            if let data = response.data {
                                single(.failure(APIError.mapError(from: response.response!, data: data)))
                            } else {
                                single(.failure(APIError.unknown("알 수 없는 네트워크 오류")))
                            }
                        }
                    }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
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
                }, with: urlRequest, interceptor: APIInterceptor()) // 인터셉터 추가
                .validate(statusCode: 200..<300)
                .responseDecodable(of: FileModel.self) { response in
                    switch response.result {
                    case .success(let data):
                        print("Decodable success: \(data)")
                        single(.success(data))
                    case .failure(_):
                        if let httpResponse = response.response, let data = response.data {
                            single(.failure(APIError.mapError(from: httpResponse, data: data)))
                        } else {
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
