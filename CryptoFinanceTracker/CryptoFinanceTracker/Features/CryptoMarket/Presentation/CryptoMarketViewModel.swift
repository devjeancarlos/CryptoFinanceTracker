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
    
    private let fetchUseCase: any FetchCryptoMarketsUseCaseProtocol
    private var currentTask: Task<Void, Never>?
    
    public init(fetchUseCase: any FetchCryptoMarketsUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
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
}
