//
//  CryptoMarketViewModel.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 18/11/26.
//

import Foundation
import Combine

@MainActor
public final class CryptoMarketViewModel: ObservableObject {
    //UI based 100% on the state of the generic machine
    @Published private(set) var state: ViewState<[Coin]> = .idle
    @Published private(set) var showOnlyFavorites: Bool = false
    
    private let fetchUseCase: any FetchCryptoMarketsUseCaseProtocol
    private let toggleFavoriteUseCase: any ToggleFavoriteCoinUseCaseProtocol
    private var currentTask: Task<Void, Never>?
    
    public init(fetchUseCase: any FetchCryptoMarketsUseCaseProtocol, toggleFavoriteUseCase: any ToggleFavoriteCoinUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }
    
    ///List filtered dynamically according to the UI selector without triggering network requests.
    public var displayCoins: [Coin] {
        guard case .succes(let coins) = state else {
            return []
        }
        return showOnlyFavorites ? coins.filter(\.isFavorite) : coins
    }
    
    public func loadMarkets(currency: String = "usd", perPage: Int = 20) {
        cancelTask()
        state = .loading
        
        currentTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let coins = try await self.fetchUseCase.execute(currency: currency, perPage: perPage)
                
                //Mandatory cancellation check before mutating the interface
                try Task.checkCancellation()
                
                if coins.isEmpty {
                    self.state = .error("No data available")
                } else {
                    self.state = .succes(coins)
                }
            } catch is CancellationError {
                //Silent abort: the task was intentionally cancelled
                self.state = .idle
            } catch let networkError as NetworkError {
                guard !Task.isCancelled else { return }
                self.state = .error(networkError.localizedDescription)
            } catch {
                self.state = .error("An unexpected error ocurred: \(error.localizedDescription)")
            }
        }
    }
    
    public func cancelTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    ///Optimistic UI udpate + asynchronous persistence in SwiftData
    public func toggleFavorite(for coinID: String) {
        guard case .succes(var currentCoins) = state, let index = currentCoins.firstIndex(where: { $0.id == coinID }) else {
            return
        }
        
        let previousCoins = currentCoins
        let targetCoin = previousCoins[index]
        
        //Inmediate optimistic mutation for an instant UI response
        currentCoins[index] = Coin(
            id: targetCoin.id,
            symbol: targetCoin.symbol,
            name: targetCoin.name,
            currentPrice: targetCoin.currentPrice,
            priceChangePercentage24h: targetCoin.priceChangePercentage24h,
            imageURL: targetCoin.imageURL,
            isFavorite: !targetCoin.isFavorite
        )
        state = .succes(currentCoins)
        
        //Disk persistance via background @ModelActor
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.toggleFavoriteUseCase.execute(coinID: coinID)
            } catch {
                //Rollback in case of a SwiftData write failure
                self.state = .succes(previousCoins)
            }
        }
    }
}
