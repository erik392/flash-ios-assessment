//
//  PortfolioViewModel.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/11.
//

import Foundation
import Combine

@MainActor
class PortfolioViewModel: ObservableObject {
    
    private let apiClient: FixerClient
    private let repository: PortfolioRepositoryType
    private var btcBalance: Double?
    
    @Published var exchangeInfo: ExchangeRateInfoModel?
    @Published var errorOcurred: Bool = false
    @Published var btcAmount: String = "" {
        didSet {
            saveBTC()
        }
    }
    
    init(apiClient: FixerClient,
         repository: PortfolioRepositoryType) {
        self.apiClient = apiClient
        self.repository = repository
    }
    
    var lastUpdated: String {
        guard let lastUpdated = exchangeInfo?.lastUpdated else { return "" }
        return "Last Updated: \(lastUpdated.formatForUI())"
    }
    
    var portfolioItems: [PorfolioItemInfoModel] {
        guard let exchangeInfo,
              let btcValue = Double(btcAmount)
        else {
            return []
        }
        
        return exchangeInfo.rates
            .map { PorfolioItemInfoModel(exchangeInfo: $0, btcValue: btcValue) }
            .sorted { ($0.currency ?? "") < ($1.currency ?? "") }
    }
    
    func fetchCurrencyValues() async {
        Task {
            do {
                let base = "BTC"
                let symbols = ["ZAR", "USD", "AUD"]
                
                let exhangeRates = try await apiClient.getExchangeRates(
                    base: base,
                    symbols: symbols
                )
                
                let toDate = Date()
                let fromDate = toDate.addingTimeInterval(-24*60*60)
                
                let exchangeFluctuations = try await apiClient.getExchangeFluctuations(
                    base: base,
                    symbols: symbols,
                    fromDate: fromDate,
                    toDate: toDate
                )

                exchangeInfo = ExchangeRateInfoModel(ratesResponse: exhangeRates, fluctuationsResponse: exchangeFluctuations)
            } catch {
                errorOcurred = true
                print("Error:", error)
            }
        }
    }
    
    func loadBTC() {
        do {
            if let value = try repository.fetchBTCValue() {
                print("Successful fetch, value: \(value)")
                btcAmount = String(value)
            }
        } catch {
            print("Failed to fetch BTC value:", error)
        }
    }

    private func saveBTC() {
        guard let value = Double(btcAmount) else { return }
        do {
            try repository.saveBTCValue(value)
            print("Successful save: \(value)")
        } catch {
            print("Failed to save BTC value:", error)
        }
    }
}
