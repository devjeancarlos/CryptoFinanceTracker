//
//  CryptoMarketRepositoryProtocol.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 6/11/26.
//

import Foundation

///Contract that defines what the market repository can do
///THe UI and Use Case will only know this protocol, never the actual implementation
public protocol CryptoMarketRepositoryProtocol: Sendable {
    func fetchMarkets(currency: String, perPage: Int) async throws -> [Coin]
    func toogleFavorite(coinID: String) async throws -> Bool
}
