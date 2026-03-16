//
//  PortfolioView.swift
//  btc-wallet
//
//  Created by Erik Egers on 2026/03/10.
//

import SwiftUI

struct PortfolioView: View {

    @StateObject var viewModel: PortfolioViewModel
    @FocusState private var isInputActive: Bool

    var body: some View {
        VStack(spacing: 0) {
            inputSection
            Divider()
            portfolioList
            Divider()
            lastUpdatedSection
        }
        .task {
            await viewModel.initialLoadBTC()
        }
        .overlay {
            if viewModel.showLoadingIndicator {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .alert(
            "Error",
            isPresented: $viewModel.showError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

private extension PortfolioView {

    // MARK: Input row
    var inputSection: some View {
        HStack {
            Text("BTC")
                .fontWeight(.medium)

            Spacer()

            TextField("Amount", text: $viewModel.btcAmount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .frame(width: 110)
                .focused($isInputActive)
                .disabled(viewModel.isLoading)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isInputActive = false
                            Task {
                                await viewModel.submitBTC()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                .onChange(of: viewModel.btcAmount) { newValue in
                    var filtered = newValue.filter { "0123456789.".contains($0) }
                    
                    let decimalCount = filtered.filter { $0 == "." }.count
                    if decimalCount > 1 {
                        let firstIndex = filtered.firstIndex(of: ".")!
                        let truncated = filtered.prefix(upTo: filtered.index(after: firstIndex))
                        + filtered.suffix(from: filtered.index(after: firstIndex)).replacingOccurrences(of: ".", with: "")
                        filtered = String(truncated)
                    }
                    
                    if filtered != newValue {
                        viewModel.btcAmount = filtered
                    }
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }

    // MARK: Portfolio list
    var portfolioList: some View {
        List(viewModel.portfolioItems, id: \.currency) { rate in
            VStack(spacing: 8) {

                HStack {
                    Text(rate.currency ?? "")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(rate.currencyValue ?? 0.0, specifier: "%.2f")")
                }

                HStack {
                    Text("Daily change:")
                    Spacer()
                    Text("\(rate.currencyChange ?? 0.0) (\(rate.changePercentage ?? 0.0, specifier: "%.2f") %)")
                        .foregroundColor((rate.currencyChange ?? 0) < 0 ? .red : .green)
                }
            }
            .padding(.vertical, 4)
        }
        .refreshable {
            Task {
                await viewModel.refreshBTC()
            }
        }
    }

    // MARK: Footer
    var lastUpdatedSection: some View {
        Text(viewModel.lastUpdated)
            .fontWeight(.medium)
            .padding()
    }
}

#Preview {
    PortfolioView(viewModel: .preview)
}
