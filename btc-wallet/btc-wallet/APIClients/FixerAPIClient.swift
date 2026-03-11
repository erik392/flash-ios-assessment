//
//  FixerAPIClient.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import Foundation

final class FixerAPIClient {

    private let networkManager = NetworkManager()

    func getExchangeRates(base: String, symbols: [String]) async throws -> ExchangeRatesResponse {
        
        var components = URLComponents(string: "https://api.apilayer.com/fixer/latest")

        components?.queryItems = [
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "symbols", value: symbols.joined(separator: "%2C"))
        ]

        return try await networkManager.fetchRequest(url: components?.url, headers: ["apikey" : "xfuV0flTkOkoilScEKNGJzxMyLbRVAYa"])
    }
    
    func getExchangeFluctuations(base: String, symbols: [String], fromDate: Date, toDate: Date) async throws -> ExchangeFluctuationsResponse {
        
        var components = URLComponents(string: "https://api.apilayer.com/fixer/fluctuation")

        components?.queryItems = [
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "symbols", value: symbols.joined(separator: "%2C")),
            URLQueryItem(name: "start_date", value: fromDate.formatForAPI()),
            URLQueryItem(name: "end_date", value: toDate.formatForAPI())
        ]

        return try await networkManager.fetchRequest(url: components?.url, headers: ["apikey" : "xfuV0flTkOkoilScEKNGJzxMyLbRVAYa"])
    }
}
