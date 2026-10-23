//
//  Endpoint.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 22/10/26.
//

import Foundation

///Define the HTTP verbs. According to Sendable
public enum HTTPMethod: String, Codable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

///Protocol that every endpoint in our app must conform to.
///By being Sendable, we ensure that endpoint's configuration can travel across threads safely.
public protocol Endpoint: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
}

extension Endpoint {
    ///Safely build the URLRequest from the endpoint's components
    public func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
