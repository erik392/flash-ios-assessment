//
//  Date+APIFormatter.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/11.
//

import Foundation

extension Date {
    
    func formatForAPI() -> String {
        self.formatted(
            .iso8601
                .year()
                .month()
                .day()
                .dateSeparator(.dash)
        )
    }
}
