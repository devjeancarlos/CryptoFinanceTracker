//
//  CoinDTO.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 6/11/26.
//

import Foundation
///Data Transfer Object (DTO) exclusive to the CoinGecko API
///Since it's not public, it remains encapsulated (internal) in the network/data layer
nonisolated struct CoinDTO: Decodable, Sendable {
    let id: String
    let symbol: String
    public let name: String
    public let currentPrice: Double?
    public let priceChangePercentage24h: Double?
    public let image: String?
    
    ///Transformation from the Data layer to the Domain layer
    func toDomain() -> Coin {
        return Coin(
            id: self.id,
            symbol: self.symbol.uppercased(),
            name: self.name,
            currentPrice: self.currentPrice ?? 0,
            priceChangePercentage24h: self.priceChangePercentage24h ?? 0,
            imageURL: URL(string: self.image ?? "")
        )
    }
}
