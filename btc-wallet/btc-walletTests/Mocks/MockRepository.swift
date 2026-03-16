//
//  MockRepository.swift
//  btc-walletTests
//
//  Created by Erik Egers on 2026/03/16.
//

@testable import btc_wallet
import Foundation

final class MockPortfolioRepository: PortfolioRepositoryType {
    
    var storedBTC: Double?
    var shouldThrow = false
    
    func fetchBTCValue() throws -> Double? {
        if shouldThrow {
            throw NSError(domain: "Error", code: 1)
        }
        return storedBTC
    }
    
    func saveBTCValue(_ value: Double) throws {
        if shouldThrow {
            throw NSError(domain: "Error", code: 1)
        }
        storedBTC = value
    }
}
