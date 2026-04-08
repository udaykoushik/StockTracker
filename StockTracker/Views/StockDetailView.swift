//
//  StockDetailView.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import SwiftUI
import Swinject

struct StockDetailView: View {
    @StateObject private var viewModel: StockDetailViewModel
    
    init(stock: Stock) {
        let vm = DIContainer.shared.container.resolve(StockDetailViewModel.self, argument: stock)!
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(viewModel.stockInfo.symbol).font(.largeTitle).fontWeight(.bold)
                    Spacer()
                    Text(String(format: "$%.2f", viewModel.stockInfo.currentPrice)).font(.title2)
                }
                
                Divider()
                
                if viewModel.isLoading {
                    ProgressView("Loading profile...").frame(maxWidth: .infinity)
                } else if let profile = viewModel.profile {
                    if let industry = profile.finnhubIndustry {
                        Text("Industry: \(industry)")
                            .font(.headline)
                    }
                    if let website = profile.weburl {
                        Text("Website: \(website)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle(viewModel.stockInfo.shortName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchProfile()
        }
    }
}
