//
//  PortfolioView.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import SwiftUI
import CoreData

struct PortfolioView: View {
    
    @StateObject private var viewModel = PortfolioViewModel(apiClient: FixerAPIClient())
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("BTC")
                        .font(.headline)
                    TextField("Amount", text: $viewModel.btcAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                List(viewModel.exchangeRates, id: \.currency) { rate in
                    HStack {
                        Text(rate.currency ?? "")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(rate.exchangeRate ?? 0.0, specifier: "%.2f")")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.fetchCurrencyValues()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

#Preview {
    PortfolioView()
}
