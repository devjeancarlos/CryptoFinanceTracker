//
//  PersistenceContainerFactory.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 25/11/26.
//

import Foundation
import SwiftData

///Feature-agnostic factory to build the SwiftData ModelContainer
///Supports disk storage (production) or in-memory storage (Unit Test)
public enum PersistenceContainerFactory {
    public static func makeContainer(
        for types: [any PersistentModel.Type],
        inMemory: Bool = false
    ) throws -> ModelContainer {
        let schema = Schema(types)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
