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
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
