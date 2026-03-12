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
    
    @Published var exchangeInfo: ExchangeRateInfoModel?
    @Published var errorOcurred: Bool = false
    
    init(apiClient: FixerClient) {
        self.apiClient = apiClient
    }
    
    var lastUpdated: String {
        guard let lastUpdated = exchangeInfo?.lastUpdated else { return "" }
        return "Last Updated: \(lastUpdated.formatForUI())"
    }
    
    func fetchCurrencyValues() async {
        Task {
            do {
                let fixerClient = FixerAPIClient()
                
                let exhangeRates = try await fixerClient.getExchangeRates(
                    base: "BTC",
                    symbols: ["ZAR", "USD", "AUD"]
                )
                
                let toDate = Date()
                let fromDate = toDate.addingTimeInterval(-24*60*60)
                
                let exchangeFluctuations = try await fixerClient.getExchangeFluctuations(
                    base: "BTC",
                    symbols: ["ZAR", "USD", "AUD"],
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
