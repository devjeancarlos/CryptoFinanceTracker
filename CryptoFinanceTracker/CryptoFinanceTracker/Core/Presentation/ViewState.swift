//
//  ViewState.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 18/11/26.
//

import Foundation

///Generic, mutually exclusive state machine
///The use of Sendable ensures that the UI state travels free of Data Races in swift 6
public enum ViewState<T: Sendable>: Sendable, Equatable where T: Equatable {
    case idle
    case loading
    case succes(T)
    case error(String)
}
