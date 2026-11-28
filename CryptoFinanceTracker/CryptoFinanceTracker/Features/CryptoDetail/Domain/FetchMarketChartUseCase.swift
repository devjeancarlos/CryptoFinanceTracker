//
//  FetchMarketChartUseCase.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 27/11/26.
//

import Foundation

///Use case for fetching the price history of a cryptocurrency
public protocol FetchMarketChartUseCaseProtocol: Sendable {
    func execute(coinID: String, currency: String, days: ChartTimeRange) async throws -> [PricePoint]
}

public struct FetchMarketChartUseCase: FetchMarketChartUseCaseProtocol {
    private let repository: any CryptoDetailRepositoryProtocol
    
    public init(repository: any CryptoDetailRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(coinID: String, currency: String, days: ChartTimeRange) async throws -> [PricePoint] {
        return try await repository.fetchMarketChart(coinID: coinID, currency: currency, days: days)
    }
}
