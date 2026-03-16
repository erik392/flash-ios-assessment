//
//  ExchangeRatesResponse.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

// MARK: - ExchangeRatesResponse
struct ExchangeRatesResponse: Codable {
    let base, date: String
    let rates: [String: Double]
    let success: Bool
    let timestamp: Int
}
