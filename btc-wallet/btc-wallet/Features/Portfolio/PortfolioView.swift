//
//  PortfolioView.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import SwiftUI
import CoreData

struct PortfolioView: View {
    
    @StateObject var viewModel: PortfolioViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("BTC")
                        .fontWeight(.medium)
                    Spacer()
                    TextField("Amount", text: $viewModel.btcAmount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        .onChange(of: viewModel.btcAmount) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                
                                let decimalCount = filtered.filter { $0 == "." }.count
                                if decimalCount > 1 {
                                    let firstIndex = filtered.firstIndex(of: ".")!
                                    let truncated = filtered.prefix(upTo: filtered.index(after: firstIndex))
                                        + filtered.suffix(from: filtered.index(after: firstIndex)).replacingOccurrences(of: ".", with: "")
                                    viewModel.btcAmount = String(truncated)
                                } else {
                                    viewModel.btcAmount = filtered
                                }
                            }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                
                Divider()
                
                List(viewModel.portfolioItems, id: \.currency) { rate in
                    HStack {
                        Text(rate.currency ?? "")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(rate.currencyValue ?? 0.0, specifier: "%.2f")")
                    }
                    .padding(.vertical, 4)
                }
                
                Divider()
                
                Text(viewModel.lastUpdated)
                    .fontWeight(.medium)
                
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
            .onAppear {
                viewModel.loadBTC()
            }
        }
    }
}

// TODO: - Fix Preview
//#Preview {
//    PortfolioView()
//}
