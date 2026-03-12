//
//  CoreDataPortfolioRepository.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/12.
//

import CoreData

protocol PortfolioRepositoryType {
    func fetchBTCValue() throws -> Double?
    func saveBTCValue(_ value: Double) throws
}

final class CoreDataPortfolioRepository: PortfolioRepositoryType {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchBTCValue() throws -> Double? {
        let request: NSFetchRequest<Portfolio> = Portfolio.fetchRequest()
        request.fetchLimit = 1

        let result = try context.fetch(request).first
        return result?.btcValue
    }

    func saveBTCValue(_ value: Double) throws {

        let request: NSFetchRequest<Portfolio> = Portfolio.fetchRequest()
        request.fetchLimit = 1

        let existing = try context.fetch(request).first

        let portfolio = existing ?? Portfolio(context: context)
        portfolio.btcValue = value

        try context.save()
    }
}
