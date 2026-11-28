//
//  PricePoint.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 27/11/26.
//

import Foundation

///Pure, concurrency-safe historical price point for crossing concurrency boundaries
nonisolated public struct PricePoint: Sendable, Identifiable, Equatable {
    public var id: Date { date }
    public let date: Date
    public let price: Double
    
    public init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }
}
