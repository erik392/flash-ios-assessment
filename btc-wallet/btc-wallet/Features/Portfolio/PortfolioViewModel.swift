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
    
    // MARK: - Dependencies
    private let apiClient: FixerClient
    private let repository: PortfolioRepositoryType
    
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var showLoadingIndicator = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    @Published var exchangeInfo: ExchangeRateInfoModel?
    @Published var btcAmount: String = "" {
        didSet {
            let filtered = btcAmount.filter { $0.isNumber || $0 == "." }
            
            if btcAmount != filtered {
                btcAmount = filtered
            }
        }
    }
    
    // MARK: - Initializer
    init(apiClient: FixerClient,
         repository: PortfolioRepositoryType) {
        self.apiClient = apiClient
        self.repository = repository
    }
    
    // MARK: - Computed Properties
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
    
    // MARK: - Public Methods
    func initialLoadBTC() async {
        loadBTC()
        if let amount = Double(btcAmount), amount != 0 {
            await updateBTC(showOverlay: true)
        }
    }
    
    func submitBTC() async {
        guard validateBTC() else { return }
        saveBTC()
        await updateBTC(showOverlay: true)
    }
    
    func refreshBTC() async {
        guard validateBTC() else { return }
        saveBTC()
        await updateBTC(showOverlay: false)
    }
    
    // MARK: - Private Methods
    private func validateBTC() -> Bool {
        guard !btcAmount.isEmpty,
              btcAmount.first != ".",
              btcAmount.last != "."
        else {
            btcAmount = ""
            errorMessage = "Enter a valid amount of BTC"
            showError = true
            return false
        }
        
        return true
    }
    
    private func updateBTC(showOverlay: Bool) async {
        guard !isLoading else { return }
        
        if showOverlay {
            showLoadingIndicator = true
        }
        
        isLoading = true
        defer {
            isLoading = false
            showLoadingIndicator = false
        }
        
        await fetchCurrencyValues()
    }
    
    private func fetchCurrencyValues() async {
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
    
    private func loadBTC() {
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
