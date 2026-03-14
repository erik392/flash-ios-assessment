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
    @Published var errorMessage: String?
    @Published var btcAmount: String = "" {
        didSet {
//            btcAmount = sanitizeBTCInput(btcAmount)
            saveBTC()
        }
    }
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    
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
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
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
                errorMessage = error.localizedDescription
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
    
    func sanitizeBTCInput(_ value: String) -> String {
        let filtered = value.filter { "0123456789.".contains($0) }
        var hasDecimal = false
        return filtered.filter { char in
            if char == "." {
                defer { hasDecimal = true }
                return !hasDecimal
            }
            return true
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
