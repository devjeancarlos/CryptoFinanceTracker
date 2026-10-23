//
//  HTTPClientProtocol.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 23/10/26.
//

import Foundation

///Main HTTP Client isolated as an actor to prevent Data Races in Swift 6
public actor HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        //Standard strategy to decode API fields like curret_price to currentPice
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func request<T>(endpoint: any Endpoint, responseModel: T.Type) async throws -> T where T : Decodable, T : Sendable {
        let request = try await endpoint.asURLRequest()
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw NetworkError.noInternetConnection
            }
            throw NetworkError.unknown(error.localizedDescription)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
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
}
