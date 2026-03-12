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
    private var btcBalance: Double?
    
    @Published var btcAmount: String = ""
    @Published var exchangeInfo: ExchangeRateInfoModel?
    @Published var errorOcurred: Bool = false
    
    init(apiClient: FixerClient) {
        self.apiClient = apiClient
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
                let fixerClient = FixerAPIClient()
                let base = "BTC"
                let symbols = ["ZAR", "USD", "AUD"]
                
                let exhangeRates = try await fixerClient.getExchangeRates(
                    base: base,
                    symbols: symbols
                )
                
                let toDate = Date()
                let fromDate = toDate.addingTimeInterval(-24*60*60)
                
                let exchangeFluctuations = try await fixerClient.getExchangeFluctuations(
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
}
