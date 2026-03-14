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
    @FocusState private var isInputActive: Bool
    @State private var isLoading = false
    
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
                        .focused($isInputActive)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isInputActive = false
                                    Task {
                                        isLoading = true
                                        await viewModel.fetchCurrencyValues()
                                        isLoading = false
                                    }
                                }
                            }
                        }
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
                    VStack {
                        HStack {
                            Text(rate.currency ?? "")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(rate.currencyValue ?? 0.0, specifier: "%.2f")")
                        }
                        .padding(.vertical, 4)
                        HStack {
                            Text("Daily change:")
                            Spacer()
                            Text("\(rate.currencyChange ?? 0.0) (\(rate.changePercentage ?? 0.0, specifier: "%.2f") %)")
                                .foregroundColor((rate.currencyChange ?? 0.0) < 0 ? .red : .green)
                        }
                    }
                }
                
                Divider()
                
                Text(viewModel.lastUpdated)
                    .fontWeight(.medium)
                
            }
            .navigationTitle("Portfolio")
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            isLoading = true
                            await viewModel.fetchCurrencyValues()
                            isLoading = false
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                viewModel.loadBTC()
            }
            .alert("Error",
                   isPresented: Binding(
                        get: { viewModel.errorMessage != nil },
                        set: { _ in viewModel.errorMessage = nil }
                   )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}

// TODO: - Fix Preview
//#Preview {
//    PortfolioView()
//}
