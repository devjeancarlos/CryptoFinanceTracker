//
//  CoinGeckoEndpoint.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 6/11/26.
//

import Foundation

///Concrete implementation of the endpoints for the cryptoconcurrency market feature
enum CoinGeckoEndpoint: Endpoint, Sendable {
    
    var baseURL: String {
        return "https://api.coingecko.com/api/v3"
    }
    
    var path: String {
        switch self {
        case . fetchMarkets:
            return "/coins/markets"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchMarkets(let currency, let perPage):
            return [
                URLQueryItem(name: "vs_currency", value: currency),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "sparkline", value: "false")
            ]
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
    
    case fetchMarkets(currency: String, perPage: Int)
}

