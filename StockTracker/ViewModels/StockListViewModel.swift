//
//  StockListViewModel.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import Foundation
import Combine

@MainActor
class StockListViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    
    private let repository: StockRepositoryProtocol
    private var refreshTask: Task<Void, Never>?
    
    var filteredStocks: [Stock] {
        if searchText.isEmpty { return stocks }
        return stocks.filter { stock in
            let nameMatch = stock.shortName.localizedCaseInsensitiveContains(searchText)
            let symbolMatch = stock.symbol.localizedCaseInsensitiveContains(searchText)
            return nameMatch || symbolMatch
        }
    }
    
    init(repository: StockRepositoryProtocol) {
        self.repository = repository
    }
    
    func onAppear() {
        startAutoRefresh()
    }
    
    func onDisappear() {
        refreshTask?.cancel()
    }
    
    private func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await fetchStocks()
                // sleep for 8 seconds as mentioned
                try? await Task.sleep(nanoseconds: 8_000_000_000)
            }
        }
    }
    
    func fetchStocks() async {
        print("Fetching market data at \(Date().formatted(date: .omitted, time: .standard))")
        do {
            let fetchedStocks = try await repository.getMarketSummary()
            self.stocks = fetchedStocks
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to fetch stocks: \(error.localizedDescription)"
        }
    }
}
