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
        #expect(vm.errorMessage == "Enter a valid amount of BTC")
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
    func lastUpdatedReturnsCorrectValue() async {
        
        let vm = makeViewModel()
        
        vm.btcAmount = "1"
        
        await vm.submitBTC()
        
        #expect(vm.lastUpdated == "Last Updated: 16 Mar 2026 at 15:56")
    }
    
    @Test
    func portfolioItemsReturnCorrectValues() async {
        
        let vm = makeViewModel()
        
        vm.btcAmount = "0.5"
        
        await vm.submitBTC()
        
        let desired = [
            PorfolioItemInfoModel(currency: "AUD", currencyValue: 52286.358228, currencyChange: nil, changePercentage: nil),
            PorfolioItemInfoModel(currency: "USD", currencyValue: 36963.775, currencyChange: nil, changePercentage: nil),
            PorfolioItemInfoModel(currency: "ZAR", currencyValue: 617984.427016, currencyChange: nil, changePercentage: nil)
        ]
        let actual = vm.portfolioItems
        
        #expect(desired[0].currency == actual[0].currency)
        #expect(desired[0].currencyValue == actual[0].currencyValue)
        #expect(desired[1].currency == actual[1].currency)
        #expect(desired[1].currencyValue == actual[1].currencyValue)
        #expect(desired[2].currency == actual[2].currency)
        #expect(desired[2].currencyValue == actual[2].currencyValue)
    }
    
    @Test
    func apiFailureShowsError() async {
        
        let api = MockFixerClient()
        api.shouldThrow = true
        
        let vm = makeViewModel(api: api)
        
        vm.btcAmount = "1"
        
        await vm.submitBTC()
        
        #expect(vm.showError == true)
        #expect(vm.errorMessage == "Failed to fetch updated converstion values. \nPlease try again later.")
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
