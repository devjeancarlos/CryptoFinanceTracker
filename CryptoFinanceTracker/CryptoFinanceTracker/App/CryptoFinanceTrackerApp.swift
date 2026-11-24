//
//  CryptoFinanceTrackerApp.swift
//  CryptoFinanceTracker
//
//  Created by Jean Carlos Ramos Cruz on 20/08/26.
//

import SwiftUI

@main
struct CryptoFinanceTrackerApp: App {
    ///Composition Root: The only point in the app that knows and instantiates the concrete classes
    ///I use @StateObject here in the root to guarantee that ViewModel lives for the entire App lifecycle
    @StateObject private var marketViewModel: CryptoMarketViewModel
    private let container: AppDIContainer
    
    init() {
        let container = AppDIContainer()
        self.container = container
        
        _marketViewModel = StateObject(wrappedValue: container.makeCryptoMarketViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            CryptoMarketView(viewModel: marketViewModel)
        }
    }
}
