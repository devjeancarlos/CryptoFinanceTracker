//
//  FetchCryptoMarketsUseCase.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 18/11/26.
//

import Foundation

///Use case contract. The ViewModel only knows this abstraction
///Conforms Sendable to guarantee thread isolation
public protocol FetchCryptoMarketsUseCaseProtocol: Sendable {
    func execute(currency: String, perPage: Int) async throws -> [Coin]
}

///Concrete implementation of the use case
public struct FetchCrytoMarketsUseCase: FetchCryptoMarketsUseCaseProtocol {
    private let repository: CryptoMarketRepositoryProtocol
    
    //Strict dependency injection
    public init(repository: any CryptoMarketRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(currency: String, perPage: Int) async throws -> [Coin] {
        //In the future, here I will merge network data with the offline favorites
        //for now, I delegate the request to the repository
        return try await repository.fetchMarkets(currency: currency, perPage: perPage)
    }
}
