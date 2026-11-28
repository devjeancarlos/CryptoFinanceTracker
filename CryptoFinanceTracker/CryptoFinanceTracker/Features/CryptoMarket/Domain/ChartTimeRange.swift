//
//  ChartTimeRange.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 27/11/26.
//

import Foundation

///Time ranges supported for the historical chart
nonisolated public enum ChartTimeRange: String, CaseIterable, Identifiable, Sendable {
    case oneDay = "1"
    case sevenDays = "7"
    case thirtyDays = "30"
    
    public var id: String { self.rawValue }
    
    public var title: String {
        switch self {
        case .oneDay: return "24H"
        case .sevenDays: return "7D"
        case .thirtyDays: return "30D"
        }
    }
}
