//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import SwiftUI
import Swinject

@main
struct StockTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            if let viewModel = DIContainer.shared.container.resolve(StockListViewModel.self) {
                StockListView(viewModel: viewModel)
            } else {
                Text("Error: Failed to resolve dependencies.")
            }
        }
    }
}
