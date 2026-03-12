//
//  PorfolioItemInfoModel.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/12.
//

import Foundation

struct PorfolioItemInfoModel: Codable {
    let currency: String?
    let currencyValue: Double?
    let currencyChange: Double?
    let changePercentage: Double?
    
    init(exchangeInfo: ExchangeRateModel, btcValue: Double) {
        self.currency = exchangeInfo.currency
        self.currencyValue = exchangeInfo.exchangeRate ?? 0.0 * btcValue
        self.currencyChange = exchangeInfo.change ?? 0.0 * btcValue
        self.changePercentage = exchangeInfo.changePercentage
    }
}
