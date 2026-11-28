//
//  CoinGeckoDetailEndpoint.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 27/11/26.
//

import Foundation

///Encapsulated (internal) endpoint for querying historical series on CoinGecko
enum CoinGeckoDetailEndpoint: Endpoint, Sendable {
    case fetchMarketChart(coinID: String, currency: String, days: String)
    
    var baseURL: String {
        "https://api.coingecko.com/api/v3"
    }
    
    var path: String {
        switch self {
        case .fetchMarketChart(let coinID, _, _) :
            return "/coins/\(coinID)/market_chart"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchMarketChart(_, let currency, let days):
            return [
                URLQueryItem(name: "vs_currency", value: currency),
                URLQueryItem(name: "days", value: days),
            ]
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
    
}
