# BTC Wallet

Single-screen SwiftUI app for viewing BTC conversion rates and portfolio value.

---

## Table of Contents

1. Overview  
2. Features  
3. Architecture
4. Folder Structure  
5. Dependencies  
6. Setup  
7. Running the App  
8. Preview / Mock Data  
9. Git Branching Strategy  

---

## Overview

![Simulator Screen Recording - iPhone 17 Pro - 2026-03-16 at 20 19 15](https://github.com/user-attachments/assets/2e79d98b-1d33-4a76-964c-791f62bbe36b)

BTC Wallet is a simple iOS app that displays:

- Current BTC exchange rates for predetermined currencies (AUD, USD and ZAR)
- Portfolio value based on BTC amount  
- Fluctuations over the last 24 hours  

Platform: iOS  
Language: Swift / SwiftUI   
Minimum iOS Deployment: 15.6

---

## Features

- Display BTC exchange rates (USD, AUD, ZAR)  
- Manual BTC input to calculate portfolio value
- Store BTC value in CoreData
- Shows last updated timestamp  
- Error handling for network / input issues  

---

## Architecture

This app uses MVVM architecture, organized by features, with separate folders for API clients, persistence, extensions, mocks, and tests. Each feature has its own Models, View, and ViewModel.

## Folder Structure

```
btc-wallet/
├─ btc-wallet.xctestplan
├─ btc-wallet.xcodeproj
├─ btc-walletApp.swift
├─ Assets.xcassets
│
├─ APIClients/
│  ├─ FixerAPIClient.swift
│  ├─ NetworkManager.swift
│  └─ ResponseModels/
│      ├─ ExchangeRatesResponse.swift
│      └─ ExchangeFluctuationsResponse.swift
│
├─ Extensions/
│  └─ Date+Formatting.swift
│
├─ Features/
│  └─ Portfolio/
│      ├─ Models/
│      │  ├─ ExchangeRateInfoModel.swift
│      │  ├─ Rate.swift
│      │  └─ PortfolioItemInfoModel.swift
│      ├─ PortfolioView.swift
│      ├─ PortfolioViewModel.swift
│      └─ PortfolioViewModel+Preview.swift
│
│  # Additional features can be added here following the same structure
│  └─ [FeatureName]/
│      ├─ Models/
│      ├─ [FeatureName]View.swift
│      ├─ [FeatureName]ViewModel.swift
│      └─ [FeatureName]ViewModel+Preview.swift
│
├─ Persistence/
│  ├─ CoreDataPortfolioRepository.swift
│  ├─ Persistence.swift
│  └─ Portfolio.xcdatamodeld
│
├─ Tests/
│  ├─ Mocks/
│  |  ├─ MockRepository.swift
│  |  ├─ MockFixerClient.swift
│  └─ PortfolioViewModelTests
```

Notes:
- MVVM Pattern: View (SwiftUI view), ViewModel (business logic / state), Model (data structures / domain logic)
- Feature-based organization allows adding new features without disrupting existing structure.

---

## Dependencies

This project does not use any third-party dependencies. All functionality is implemented using Apple's native frameworks.

---

## Setup

1. Clone the repository:
```bash
git clone https://github.com/erik392/flash-ios-assessment
```
2. Open the `.xcodeproj` in Xcode  
3. Build the project (`Cmd + B`)  

---

## Running the App

- Select the target device / simulator  
- Run the app (`Cmd + R`)  

---

## Preview / Mock Data

- SwiftUI previews use a synchronous mock ViewModel:
```swift
PortfolioView(viewModel: PortfolioViewModel.preview)
```
- Previews populate btcAmount and exchange rates to display UI without real network calls.  

---

## Git Branching Strategy

We follow a simple Git workflow:

- master – Production-ready code  
- develop – Integration branch for features / fixes  
- feature/[name] – Each new feature  

Merging rules:
- All merges to develop and master go through Pull Requests  
- Code must pass local tests / linting before merge  

