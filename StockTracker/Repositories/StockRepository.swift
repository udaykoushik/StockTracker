//
//  StockRepository.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import Foundation

protocol StockRepositoryProtocol {
    func getMarketSummary() async throws -> [Stock]
    func getStockDetails(symbol: String) async throws -> CompanyProfileResponse
}

class StockRepository: StockRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    // Some sample stocks -- scoped for the take home assignment
    private let sampleStocks = [
            ("AAPL", "Apple Inc."), ("MSFT", "Microsoft"),
            ("GOOGL", "Alphabet"), ("TSLA", "Tesla"),
            ("AMZN", "Amazon"), ("NVDA", "Nvidia")
        ]
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getMarketSummary() async throws -> [Stock] {
        /* NOTE: Since there is no "market/v2/get-summary" API like in the earlier yahoo finance site,
                we need to fetch data related to these sampleStocks in a concurent manner.
                We are trying to create a market-summary based on individual "/stock/profile2" APIs.
                Also, Finnhub’s free tier limitations.
         */
        return try await withThrowingTaskGroup(of: Stock?.self) { group in
            var fetchedStocks: [Stock] = []
            
            for (symbol, name) in sampleStocks {
                group.addTask {
                    do {
                        let query = [URLQueryItem(name: "symbol", value: symbol)]
                        let quote: QuoteResponse = try await self.networkService.fetchData(endpoint: "quote", queryItems: query)
                        return Stock(symbol: symbol, shortName: name, currentPrice: quote.c, changePercent: quote.dp)
                    } catch {
                        return nil // this will allow the subsequent calls to go thru
                    }
                }
            }
            
            for try await stock in group {
                if let stock = stock {
                    fetchedStocks.append(stock)
                }
            }
            
            return fetchedStocks.sorted { $0.symbol < $1.symbol }
        }
    }
    
    func getStockDetails(symbol: String) async throws -> CompanyProfileResponse {
        let query = [URLQueryItem(name: "symbol", value: symbol)]
        return try await networkService.fetchData(endpoint: "stock/profile2", queryItems: query)
    }
}

