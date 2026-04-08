//
//  StockTrackerTests.swift
//  StockTrackerTests
//
//  Created by Uday Koushik on 29/03/26.
//

import XCTest
@testable import StockTracker

@MainActor
final class StockListViewModelTests: XCTestCase {
    
    class MockStockRepository: StockRepositoryProtocol {
        var mockStocks: [Stock] = []
        var mockProfileResponse: CompanyProfileResponse?
        var shouldThrowError = false
        
        func getMarketSummary() async throws -> [Stock] {
            if shouldThrowError {
                throw URLError(.badServerResponse)
            }
            return mockStocks
        }
        
        func getStockDetails(symbol: String) async throws -> CompanyProfileResponse {
            if shouldThrowError {
                throw URLError(.badServerResponse)
            }
            if let response = mockProfileResponse {
                return response
            }
            throw URLError(.unknown)
        }
    }
    
    var viewModel: StockListViewModel!
    var mockRepository: MockStockRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockStockRepository()
        viewModel = StockListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testFetchStocks_Success_PopulatesList() async {
        let aapl = Stock(symbol: "AAPL", shortName: "Apple Inc.", currentPrice: 150.0, changePercent: 1.25)
        mockRepository.mockStocks = [aapl]
        
        await viewModel.fetchStocks()
        
        XCTAssertEqual(viewModel.stocks.count, 1)
        XCTAssertEqual(viewModel.stocks.first?.symbol, "AAPL")
        XCTAssertEqual(viewModel.stocks.first?.currentPrice, 150.0)
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on a successful fetch.")
    }
    
    func testFetchStocks_Failure_SetsErrorMessage() async {
        mockRepository.shouldThrowError = true
        
        await viewModel.fetchStocks()
        
        XCTAssertTrue(viewModel.stocks.isEmpty, "Stocks array should remain empty on failure.")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be populated when an error is thrown.")
    }
    
    func testSearchFiltering_ReturnsCorrectStocks() {
        let aapl = Stock(symbol: "AAPL", shortName: "Apple Inc.", currentPrice: 150.0, changePercent: 1.25)
        let msft = Stock(symbol: "MSFT", shortName: "Microsoft Corp.", currentPrice: 300.0, changePercent: 0.5)
        let tsla = Stock(symbol: "TSLA", shortName: "Tesla", currentPrice: 200.0, changePercent: -2.0)
        
        viewModel.stocks = [aapl, msft, tsla]
        
        viewModel.searchText = "MSFT"
        XCTAssertEqual(viewModel.filteredStocks.count, 1)
        XCTAssertEqual(viewModel.filteredStocks.first?.symbol, "MSFT")
        
        viewModel.searchText = "apple"
        XCTAssertEqual(viewModel.filteredStocks.count, 1)
        XCTAssertEqual(viewModel.filteredStocks.first?.symbol, "AAPL")
        
        viewModel.searchText = "Google"
        XCTAssertTrue(viewModel.filteredStocks.isEmpty)
        
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredStocks.count, 3)
    }
}
