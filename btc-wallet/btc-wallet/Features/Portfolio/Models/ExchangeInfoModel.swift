//
//  ExchangeInfoModel.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/11.
//

import Foundation

struct ExchangeRateInfoModel {
    let base: String
    let lastUpdated: Date
    let rates: [ExchangeRateModel]
    
    init(ratesResponse: ExchangeRatesResponse, fluctuationsResponse: ExchangeFluctuationsResponse) {
        self.base = ratesResponse.base
        self.lastUpdated = Date(timeIntervalSince1970: TimeInterval(ratesResponse.timestamp))
        self.rates = ratesResponse.rates.keys.compactMap { currency in
            guard let exchangeRate = ratesResponse.rates[currency] else { return nil }
            
            let rateInfo = fluctuationsResponse.rates[currency]
            let change = rateInfo?.change
            let changePercentage = rateInfo?.changePct
            
            return ExchangeRateModel(
                currency: currency,
                exchangeRate: exchangeRate,
                change: change,
                changePercentage: changePercentage
            )
        }
    }
}

struct ExchangeRateModel {
    let currency: String?
    let exchangeRate: Double?
    let change: Double?
    let changePercentage: Double?
}
