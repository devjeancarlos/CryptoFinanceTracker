//
//  CryptoLocalDataSource.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 25/11/26.
//

import Foundation
import SwiftData

///Local access contract. Conforms to Sendable to be injected into the Repository
public protocol CryptoLocalDataSourceProtocol: Sendable {
    func fetchCachedCoins() async throws -> [Coin]
    func saveCoins(_ coins: [Coin]) async throws
    func toggleFavorite(coinID: String) async throws -> Bool
}

///SwiftData actor that runs all disk operations on a background thread
@ModelActor
public actor CryptoLocalDataSource: CryptoLocalDataSourceProtocol {
    public func fetchCachedCoins() async throws -> [Coin] {
        //Sort by price descending (approximation to market ranking)
        let descriptor = FetchDescriptor<CachedCoinEntity>(
            sortBy: [SortDescriptor(\.currentPrice, order: .reverse)]
        )
        let entities = try modelContext.fetch(descriptor)
        
        return entities.map { $0.toDomain() }
    }
    
    public func saveCoins(_ coins: [Coin]) async throws {
        //Read the current records so I don't lose the favorites marked by the user
        let existingEntities = try modelContext.fetch(FetchDescriptor<CachedCoinEntity>())
        let existingMap = Dictionary(uniqueKeysWithValues: existingEntities.map { ($0.id, $0) })
        
        for coin in coins {
            if let existing = existingMap[coin.id] {
                //Upsert: update prices and metadata while preserving isFavorite
                existing.symbol = coin.symbol
                existing.name = coin.name
                existing.currentPrice = coin.currentPrice
                existing.priceChangePercentage24h = coin.priceChangePercentage24h
                existing.imageURLString = coin.imageURL?.absoluteString
                existing.lastUpdated = .now
            } else {
                //Insert: new record
                let newEntity = CachedCoinEntity(
                    id: coin.id,
                    symbol: coin.symbol,
                    name: coin.name,
                    currentPrice: coin.currentPrice,
                    priceChangePercentage24h: coin.priceChangePercentage24h,
                    imageURLString: coin.imageURL?.absoluteString,
                    isFavorite: coin.isFavorite,
                    lastUpdated: .now
                    )
                modelContext.insert(newEntity)
            }
            
            if modelContext.hasChanges {
                try modelContext.save()
            }
        }
    }
    
    @discardableResult
    public func toggleFavorite(coinID: String) async throws -> Bool {
        let predicate = #Predicate<CachedCoinEntity> { $0.id == coinID }
        var descriptor = FetchDescriptor<CachedCoinEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        guard let entity = try modelContext.fetch(descriptor).first else {
            return false
        }
        
        entity.isFavorite.toggle()
        
        try modelContext.save()
        
        return entity.isFavorite
    }
}
