//
//  btc_walletApp.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import SwiftUI
import CoreData

@main
struct btc_walletApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        let context = persistenceController.container.viewContext
        let repository = CoreDataPortfolioRepository(context: context)
        let viewModel = PortfolioViewModel(
            apiClient: FixerAPIClient(),
            repository: repository)
        
        WindowGroup {
            PortfolioView(viewModel: viewModel)
                .environment(\.managedObjectContext, context)
        }
    }
}
