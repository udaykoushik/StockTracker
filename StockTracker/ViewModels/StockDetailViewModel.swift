//
//  StockDetailViewModel.swift
//  StockTracker
//
//  Created by Uday Koushik on 08/04/26.
//

import Foundation
import Combine

@MainActor
class StockDetailViewModel: ObservableObject {
    @Published var profile: CompanyProfileResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let stockInfo: Stock
    private let repository: StockRepositoryProtocol
    
    init(stockInfo: Stock, repository: StockRepositoryProtocol) {
        self.stockInfo = stockInfo
        self.repository = repository
    }
    
    func fetchProfile() async {
        isLoading = true
        do {
            self.profile = try await repository.getStockDetails(symbol: stockInfo.symbol)
        } catch {
            self.errorMessage = "Failed to load company profile."
        }
        isLoading = false
    }
}
