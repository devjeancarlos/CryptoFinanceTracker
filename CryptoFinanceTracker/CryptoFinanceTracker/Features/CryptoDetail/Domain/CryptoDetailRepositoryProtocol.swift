//
//  CryptoDetailRepositoryProtocol.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 27/11/26.
//

import Foundation


///Contract of the historical detail repository
public protocol CryptoDetailRepositoryProtocol {
    func fetchMarketChart(coinID: String, currency: String, days: ChartTimeRange) async throws -> [PricePoint]
}
