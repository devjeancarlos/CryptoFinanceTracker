//
//  CachedCoinEntity.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 25/11/26.
//

import Foundation
import SwiftData

///Local persistance model in SwiftData
///Marked as inosolated to avoid the project's @MainActor inference
///and allow asfe manipulation from a background @ModelActor
@Model
nonisolated final class CachedCoinEntity {
    @Attribute(.unique) var id: String
    var symbol: String
    var name: String
    var currentPrice: Double
    var priceChangePercentage24h: Double
    var imageURLString: String?
    var isFavorite: Bool
    var lastUpdated: Date
    
    init(id: String, symbol: String, name: String, currentPrice: Double, priceChangePercentage24h: Double, imageURLString: String?, isFavorite: Bool = false, lastUpdated: Date = .now) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.priceChangePercentage24h = priceChangePercentage24h
        self.imageURLString = imageURLString
        self.isFavorite = isFavorite
        self.lastUpdated = lastUpdated
    }
    
    ///Maps the mutable SwiftData object to a Sendable entity that is safe to cross threads
    func toDomain() -> Coin {
        Coin(
            id: id,
            symbol: symbol,
            name: name,
            currentPrice: currentPrice,
            priceChangePercentage24h: priceChangePercentage24h,
            imageURL: imageURLString.flatMap { URL(string: $0) },
            isFavorite: isFavorite
        )
    }
}
