//
//  NetworkError.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 20/08/26.
//

import Foundation

///Represents the controlled errors of our network layer
///Conforms Sendable to ensure it is safe pass across different concurrency boundaries
enum NetworkError: Error, LocalizedError, Sendable, Equatable {
    case invalidURL
    case invalidResponse
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case decodingError(String)
    case noInternetConnection
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid"
        case .invalidResponse:
            return "The response from the server was invalid"
        case .rateLimitExceeded:
            return "You have exceeded the request limit. Try again later"
        case .serverError(statusCode: let statusCode):
            return "The server returned an error with status code: \(statusCode)"
        case .decodingError(let message):
            return "Failed to decode the response. \(message)"
        case .noInternetConnection:
            return "There is no internet connection. Please check your network settings."
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
