//
//  ExchangeFluctuationsResponse.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

// MARK: - ExchangeFluctuations
struct ExchangeFluctuationsResponse: Codable {
    let base, endDate: String
    let fluctuation: Bool
    let rates: [String: Rate]
    let startDate: String
    let success: Bool

    enum CodingKeys: String, CodingKey {
        case base
        case endDate = "end_date"
        case fluctuation, rates
        case startDate = "start_date"
        case success
    }
}

// MARK: - Rate
struct Rate: Codable {
    let change, changePct, endRate, startRate: Double

    enum CodingKeys: String, CodingKey {
        case change
        case changePct = "change_pct"
        case endRate = "end_rate"
        case startRate = "start_rate"
    }
}
