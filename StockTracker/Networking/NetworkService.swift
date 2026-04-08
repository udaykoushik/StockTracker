//
//  NetworkService.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchData<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]?) async throws -> T
}

class NetworkService: NetworkServiceProtocol {

    func fetchData<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]?) async throws -> T {
        var components = URLComponents(string: Environment.baseURL + endpoint)!
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue(Environment.apikey, forHTTPHeaderField: "X-Finnhub-Token")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
}
