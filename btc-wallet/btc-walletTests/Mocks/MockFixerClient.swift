//
//  MockFixerClient.swift
//  btc-walletTests
//
//  Created by Erik Egers on 2026/03/16.
//

@testable import btc_wallet
import Foundation

final class MockFixerClient: FixerClient {
    
    var shouldThrow = false
    
    func getExchangeRates(base: String, symbols: [String]) async throws -> ExchangeRatesResponse {
        if shouldThrow {
            throw CustomError.apiError(1)
        }
        
        return ExchangeRatesResponse(
            base: "BTC",
            date: "2026-03-16",
            rates: [
                "AUD": 104572.716456,
                "USD": 73927.55,
                "ZAR": 1235968.854032
            ],
            success: true,
            timestamp: 1773669365
        )
    }
    
    func getExchangeFluctuations(
        base: String,
        symbols: [String],
        fromDate: Date,
        toDate: Date
    ) async throws -> ExchangeFluctuationsResponse {
        
        if shouldThrow {
            throw CustomError.apiError(1)
        }
        
        return ExchangeFluctuationsResponse(
            base: "BTC",
            endDate: "2026-03-16",
            fluctuation: true,
            rates: [
                "AUD": Rate(
                    change: 777.2771,
                    changePct: 0.7478,
                    endRate: 104713.483314,
                    startRate: 103936.206164
                ),
                "USD": Rate(
                    change: 1,
                    changePct: 1.7061,
                    endRate: 74053.2,
                    startRate: 72810.95
                ),
                "ZAR": Rate(
                    change: 7,
                    changePct: 0.5924,
                    endRate: 1237107.580845,
                    startRate: 1229821.724234
                )
            ],
            startDate: "2026-03-15",
            success: true
        )
    }
}
