//
//  ToggleFavoriteCoinUseCase.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 26/11/26.
//

import Foundation

///Use case contract for toggling the favorite state of a coin
public protocol ToggleFavoriteCoinUseCaseProtocol: Sendable {
    @discardableResult
    func execute(coinID: String) async throws -> Bool
}

public struct ToggleFavoriteCoinUseCase: ToggleFavoriteCoinUseCaseProtocol {
    private let repository: any CryptoMarketRepositoryProtocol
    
    public init(repository: any CryptoMarketRepositoryProtocol) {
        self.repository = repository
    }
    
    @discardableResult
    public func execute(coinID: String) async throws -> Bool {
        return try await repository.toogleFavorite(coinID: coinID)
    }
}
