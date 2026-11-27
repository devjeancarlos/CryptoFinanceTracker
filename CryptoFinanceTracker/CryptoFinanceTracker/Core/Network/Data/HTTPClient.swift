//
//  HTTPClientProtocol.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 23/10/26.
//

import Foundation

///Main HTTP Client isolated as an actor to prevent Data Races in Swift 6
///Includes a retry policy with Exponential backoff for transient errors
public actor HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let maxRetries: Int
    private let baseRetryDelay: Duration
    
    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder(), maxRetries: Int = 2, baseRetryDelay: Duration = .milliseconds(500)) {
        //Standard strategy to decode API fields like current_price to currentPice
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        self.session = session
        self.decoder = decoder
        self.maxRetries = max(0, maxRetries)
        self.baseRetryDelay = baseRetryDelay
    }
    
    public func request<T: Decodable & Sendable>(endpoint: any Endpoint, responseModel: T.Type) async throws -> T where T : Decodable, T : Sendable {
        let request = try await endpoint.asURLRequest()
        var currentAttempt = 0
        
        while true {
            try Task.checkCancellation()
            
            do {
                return try await performSingleRequest(request: request, responseModel: responseModel)
            } catch let error as NetworkError {
                guard currentAttempt < maxRetries, shouldRetry(error: error) else {
                    throw error
                }
                
                currentAttempt += 1
                // Exponential Backoff: baseDelay * 2^(attempt - 1)
                let multiplier = 1 << (currentAttempt - 1)
                let delay = baseRetryDelay * multiplier
                try await Task.sleep(for: delay)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw NetworkError.unknown(error.localizedDescription)
            }
        }
    }
    
    //MARK: Private helpers
    private func performSingleRequest<T: Sendable & Decodable>(request: URLRequest, responseModel: T.Type) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternetConnection
            case .timedOut, .networkConnectionLost:
                throw NetworkError.serverError(statusCode: 408)
            default:
                throw NetworkError.unknown(error.localizedDescription)
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                throw NetworkError.decodingError(decodingError.localizedDescription)
            } catch {
                throw NetworkError.decodingError("Error processing the JSON")
            }
        case 429:
            throw NetworkError.rateLimitExceeded
        case 400...499:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.unknown("Unrecognized status code: \(httpResponse.statusCode)")
        }
    }
    
    ///Determinate wheter a failure is transient and warrants an automatic retry
    private func shouldRetry(error: NetworkError) -> Bool {
        switch error {
        case .rateLimitExceeded:
            return true
        case .serverError(let statusCode):
            return statusCode == 408 || (500...599).contains(statusCode)
        case .invalidURL, .invalidResponse, .decodingError, .noInternetConnection, .unknown:
            return false
        }
    }
}
