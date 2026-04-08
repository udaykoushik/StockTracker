//
//  StockModels.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import Foundation

struct Stock: Identifiable, Sendable {
    var id: String { symbol }
    let symbol: String
    let shortName: String
    var currentPrice: Double
    var changePercent: Double
}

struct QuoteResponse: Decodable, Sendable {
    let c: Double // Current price
    let dp: Double // Percent change
}

// Finnhub's /stock/profile2 endpoint response
struct CompanyProfileResponse: Decodable, Sendable {
    let name: String?
    let ticker: String?
    let finnhubIndustry: String?
    let weburl: String?
}
