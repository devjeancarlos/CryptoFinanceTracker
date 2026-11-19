//
//  CryptoMarketRepository.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 6/11/26.
//

import Foundation

///Concrete implementation of the repository
public struct CryptoMarketRepository: CryptoMarketRepositoryProtocol {
    private let httpClient: any HTTPClientProtocol
    
    //Strict Dependency injection. The abstraction is injected, not the concrete class
    public init(httpClient: any HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    public func fetchMarkets(currency: String, perPage: Int) async throws -> [Coin] {
        let endpoint = CoinGeckoEndpoint.fetchMarkets(currency: currency, perPage: perPage)
        
        let dtos = try await httpClient.request(
            endpoint: endpoint,
            responseModel: [CoinDTO].self
        )
        
        return dtos.map { $0.toDomain() }
    }
}
