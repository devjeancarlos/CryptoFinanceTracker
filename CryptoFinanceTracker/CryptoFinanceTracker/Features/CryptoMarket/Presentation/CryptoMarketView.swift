//
//  CryptoMarketView.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 24/11/26.
//

import SwiftUI

struct CryptoMarketView: View {
    ///I use @ObservedObject because the instance is assembled from the Composition root
    @ObservedObject var viewModel: CryptoMarketViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear
                case .loading:
                    ProgressView("Fetching real-time prices...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .succes(let coins):
                    marketListContent
                case .error(let message):
                    ContentUnavailableView {
                        Label("Connection error", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") {
                            viewModel.loadMarkets()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Crypto Market")
            .onAppear {
                if case .idle = self.viewModel.state {
                    viewModel.loadMarkets()
                }
            }
            .onDisappear {
                //preventive cancellation when leaving the screen to free up resources
                viewModel.cancelTask()
            }
        }
    }
    
    @ViewBuilder
    private var marketListContent: some View {
        let coins = viewModel.displayCoins
        
        if coins.isEmpty && viewModel.showOnlyFavorites {
            ContentUnavailableView("Without favorites, there are no coins to show.",
            systemImage: "star.slash",
            description: Text("Taph the start on any cryptoconcurreny to save it here and view it offline"))
        } else {
            List(coins) { coin in
                CoinRowView(coin: coin) {
                    viewModel.toggleFavorite(for: coin.id)
                }
            }
            .listStyle(.plain)
            .refreshable {
                viewModel.loadMarkets()
            }
        }
    }
}
