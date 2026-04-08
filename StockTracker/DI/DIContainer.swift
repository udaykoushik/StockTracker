//
//  DIContainer.swift
//  StockTracker
//
//  Created by Uday Koushik on 29/03/26.
//

import Foundation
import Swinject

class DIContainer {
    static let shared = DIContainer()
    let container = Container()
    
    private init() {
        registerServices()
    }
    
    private func registerServices() {
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkService()
        }.inObjectScope(.container)
        
        container.register(StockRepositoryProtocol.self) { r in
            StockRepository(networkService: r.resolve(NetworkServiceProtocol.self)!)
        }
        
        container.register(StockListViewModel.self) { r in
            StockListViewModel(repository: r.resolve(StockRepositoryProtocol.self)!)
        }
        
        container.register(StockDetailViewModel.self) { (r, stock: Stock) in
            StockDetailViewModel(
                stockInfo: stock,
                repository: r.resolve(StockRepositoryProtocol.self)!
            )
        }
    }
}
