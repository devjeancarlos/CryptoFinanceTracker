//
//  Coin.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 6/11/26.
//

import Foundation

///Pure entity of business rule
///Conforms to 'Identifiable' for SwiftUI, and 'Sendable' to cross asynchronous threads
nonisolated public struct Coin: Identifiable, Sendable, Equatable {
    public let id: String
    public let symbol: String
    public let name: String
    public let currentPrice: Double
    public let priceChangePercentage24h: Double
    public let imageURL: URL?
    public let isFavorite: Bool
    
    public init(id: String, symbol: String, name: String, currentPrice: Double, priceChangePercentage24h: Double, imageURL: URL?, isFavorite: Bool = false) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.priceChangePercentage24h = priceChangePercentage24h
        self.imageURL = imageURL
        self.isFavorite = isFavorite
    }
}
