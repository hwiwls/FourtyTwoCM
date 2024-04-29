//
//  TargetType.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
    
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var header: [String: String] { get }
    var parameter: String? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    
}

extension TargetType {
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems

        var urlRequest = try URLRequest(url: components?.url ?? url, method: method)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpBody = body  

        print("Request URL: \(urlRequest.url?.absoluteString ?? "Invalid URL")")
        print("Headers: \(String(describing: urlRequest.allHTTPHeaderFields))")
        print("HTTP Body: \(String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) ?? "No body data")")
        
        return urlRequest
    }

}
