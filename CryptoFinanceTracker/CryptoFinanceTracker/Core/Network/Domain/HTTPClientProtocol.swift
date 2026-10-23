//
//  HTTPClientProtocol.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 23/10/26.
//

import Foundation

///Network client interface for dependency inversion
///Conforms to Sendable to allow safe injection across concurrency boundaries.
public protocol HTTPClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T
}
