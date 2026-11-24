//
//  CoinRowView.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 24/11/26.
//

import SwiftUI

///Pure leaf component: receives a value type (coin) and doesn't know the ViewModel
struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: coin.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 36, height: 36)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                case .failure(let error):
                    Image(systemName: "bitcoinsign.circe.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.secondary)
                    
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(coin.symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(coin.currentPrice, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                
                priceChangeBadge
            }
        }
        .padding(.vertical, 4)
    }
    
    private var priceChangeBadge: some View {
        let isPositive = coin.priceChangePercentage24h >= 0
        return HStack(spacing: 2) {
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
            Text("\(abs(coin.priceChangePercentage24h), specifier: "%.2f")%")
        }
        .font(.caption2)
        .fontWeight(.semibold)
        .foregroundStyle(isPositive ? .green : .red)
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background((isPositive ? Color.green : Color.red).opacity(0.12))
        .clipShape(Capsule())
    }
}
