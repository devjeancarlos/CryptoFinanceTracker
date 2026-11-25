//
//  AppDIContainer.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 24/11/26.
//

import Foundation
import SwiftData

///Centralized Dependency injection container (Composition root)
///isolated on @MainActor to assemble both Sendable infraestructure and UI ViewModels
@MainActor
final class AppDIContainer {
    //MARK: Core Infrastructure (Shared across the App lifecycle)
    private let httpClient: any HTTPClientProtocol
    private let modelContainer: ModelContainer
    private let cryptoLocalDataSource: any CryptoLocalDataSourceProtocol
    
    //Alows injecting a mock client for UI Test or Swift Previews
    //Receives an optional to resolve the default dependency within the @MainActor context
    init(httpClient: (any HTTPClientProtocol)? = nil, inMemoryStorage: Bool = false) {
        self.httpClient = httpClient ?? HTTPClient()
        
        do {
            let container = try PersistenceContainerFactory.makeContainer(
                for: [CachedCoinEntity.self],
                inMemory: inMemoryStorage
                )
            self.modelContainer = container
            self.cryptoLocalDataSource = CryptoLocalDataSource(modelContainer: container)
        } catch {
            fatalError("Critical error initializing SwiftData local storage \(error)")
        }
    }
    
    //MARK: Feature Factories: CryptoMarket
    func makeCryptoMarketViewModel() -> CryptoMarketViewModel {
        let repository = CryptoMarketRepository(httpClient: httpClient, localDataSource: cryptoLocalDataSource)
        let fetchUseCase = FetchCrytoMarketsUseCase(repository: repository)
        
        return CryptoMarketViewModel(fetchUseCase: fetchUseCase)
    }
}
