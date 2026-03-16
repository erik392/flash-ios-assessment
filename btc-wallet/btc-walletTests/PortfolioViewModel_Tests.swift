//
//  PortfolioViewModel_Tests.swift
//  btc-walletTests
//
//  Created by Erik Egers on 2026/03/16.
//

import Foundation
import Testing
@testable import btc_wallet

@MainActor
struct PortfolioViewModelTests {
    
    // MARK: Helpers
    
    func makeViewModel(
        api: MockFixerClient = MockFixerClient(),
        repo: MockPortfolioRepository = MockPortfolioRepository()
    ) -> PortfolioViewModel {
        PortfolioViewModel(apiClient: api, repository: repo)
    }
    
    @Test
    func initialLoadLoadsSavedBTC() async {
        
        let repo = MockPortfolioRepository()
        repo.storedBTC = 1.5
        
        let vm = makeViewModel(repo: repo)
        
        await vm.initialLoadBTC()
        
        #expect(vm.btcAmount == "1.5")
    }
    
    @Test
    func submitBTCWithInvalidValueShowsError() async {
        
        let vm = makeViewModel()
        
        vm.btcAmount = "."
        
        await vm.submitBTC()
        
        #expect(vm.showError == true)
        #expect(vm.errorMessage != nil)
    }
    
    @Test
    func submitBTCFetchesExchangeRates() async {
        
        let vm = makeViewModel()
        
        vm.btcAmount = "1"
        
        await vm.submitBTC()
        
        let desired = ExchangeRateInfoModel(base: "BTC", lastUpdated: Date(timeIntervalSince1970: 1773669365), rates: [
            ExchangeRateModel(currency: "AUD", exchangeRate: 104572.716456, change: 343, changePercentage: 0.34),
            ExchangeRateModel(currency: "USD", exchangeRate: 73927.55, change: 43, changePercentage: 0.343),
            ExchangeRateModel(currency: "ZAR", exchangeRate: 1235968.854032, change: 34, changePercentage: 0.434)
        ])
        
        let actualRates = vm.exchangeInfo?.rates.sorted { ($0.currency ?? "") < ($1.currency ?? "") }
        
        #expect(vm.exchangeInfo?.base == desired.base)
        #expect(vm.exchangeInfo?.lastUpdated == desired.lastUpdated)
        #expect(actualRates?[0].exchangeRate == desired.rates[0].exchangeRate)
        #expect(actualRates?[0].currency == desired.rates[0].currency)
        #expect(actualRates?[1].exchangeRate == desired.rates[1].exchangeRate)
        #expect(actualRates?[1].currency == desired.rates[1].currency)
        #expect(actualRates?[2].exchangeRate == desired.rates[2].exchangeRate)
        #expect(actualRates?[2].currency == desired.rates[2].currency)
    }
    
    @Test
    func apiFailureShowsError() async {
        
        let api = MockFixerClient()
        api.shouldThrow = true
        
        let vm = makeViewModel(api: api)
        
        vm.btcAmount = "1"
        
        await vm.submitBTC()
        
        #expect(vm.showError == true)
        #expect(vm.exchangeInfo == nil)
    }
    
    @Test
    func submitBTCSavesValue() async {
        
        let repo = MockPortfolioRepository()
        
        let vm = makeViewModel(repo: repo)
        
        vm.btcAmount = "2"
        
        await vm.submitBTC()
        
        #expect(repo.storedBTC == 2)
    }
    
    @Test
    func refreshDoesNotShowLoadingOverlay() async {
        
        let vm = makeViewModel()
        
        vm.btcAmount = "1"
        
        await vm.refreshBTC()
        
        #expect(vm.showLoadingIndicator == false)
    }
}
