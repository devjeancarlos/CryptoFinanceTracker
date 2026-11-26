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
    private let localDataSource: any CryptoLocalDataSourceProtocol
    
    //Strict Dependency injection. The abstraction is injected, not the concrete class
    public init(httpClient: any HTTPClientProtocol, localDataSource: any CryptoLocalDataSourceProtocol) {
        self.httpClient = httpClient
        self.localDataSource = localDataSource
    }
    
    public func fetchMarkets(currency: String, perPage: Int) async throws -> [Coin] {
        let endpoint = CoinGeckoEndpoint.fetchMarkets(currency: currency, perPage: perPage)
        
        do {
            //Try to obtain data from CoinGecko
            let dtos = try await httpClient.request(
                endpoint: endpoint,
                responseModel: [CoinDTO].self
            )
            
            let remoteCoins = dtos.map { $0.toDomain() }
            
            //I persist in SwiftData (background thread) while preserving favorites
            try await localDataSource.saveCoins(remoteCoins)
            
            //I return from local to ensure that each Coin reflects its real isFavorite state
            return try await localDataSource.fetchCachedCoins()
        } catch let error as NetworkError where error == .noInternetConnection || error == .rateLimitExceeded {
            //Offline callback: if there is no network or CoinGecko blocked me with HTTP 429, I read the cache
            let cachedCoins = try await localDataSource.fetchCachedCoins()
            if !currency.isEmpty {
                return cachedCoins
            }
            
            throw error
        }
    }
    
    //If caller of this function ignores the return value, don't show a warning
    @discardableResult
    public func toogleFavorite(coinID: String) async throws -> Bool {
        return try await localDataSource.toggleFavorite(coinID: coinID)
    }
}
