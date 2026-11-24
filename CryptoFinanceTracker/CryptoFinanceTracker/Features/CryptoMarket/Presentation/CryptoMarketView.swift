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
                    List(coins) { coin in
                        CoinRowView(coin: coin)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.loadMarkets()
                    }
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
}
