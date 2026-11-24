//
//  AppDIContainer.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 24/11/26.
//

import Foundation

///Centralized Dependency injection container (Composition root)
///isolated on @MainActor to assemble both Sendable infraestructure and UI ViewModels
@MainActor
final class AppDIContainer {
    //MARK: Core Infrastructure (Shared across the App lifecycle)
    private let httpClient: any HTTPClientProtocol
    
    //Alows injecting a mock client for UI Test or Swift Previews
    //Receives an optional to resolve the default dependency within the @MainActor context
    init(httpClient: (any HTTPClientProtocol)? = nil) {
        self.httpClient = httpClient ?? HTTPClient()
    }
    
    //MARK: Feature Factories: CryptoMarket
    func makeCryptoMarketViewModel() -> CryptoMarketViewModel {
        let repository = CryptoMarketRepository(httpClient: httpClient)
        let fetchUseCase = FetchCrytoMarketsUseCase(repository: repository)
        
        return CryptoMarketViewModel(fetchUseCase: fetchUseCase)
    }
}
