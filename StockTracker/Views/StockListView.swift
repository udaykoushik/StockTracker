//
//  StockListView.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel: StockListViewModel
    
    init(viewModel: StockListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.filteredStocks) { stock in
                NavigationLink(destination: StockDetailView(stock: stock)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stock.symbol).font(.headline)
                            Text(stock.shortName).font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(String(format: "$%.2f", stock.currentPrice))
                                .fontWeight(.bold)
                            
                            let isPositive = stock.changePercent >= 0
                            let sign = isPositive ? "+" : ""
                            
                            Text("\(sign)\(String(format: "%.2f", stock.changePercent))%")
                                .foregroundColor(isPositive ? .green : .red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Market Summary")
            .searchable(text: $viewModel.searchText, prompt: "Search Stocks")
            .onAppear { viewModel.onAppear() }
            .onDisappear { viewModel.onDisappear() }
        }
    }
}
