# Getting Started with ARCPurchasing

Learn how to integrate ARCPurchasing into your app.

## Overview

This guide walks you through the essential steps to set up and use ARCPurchasing in your iOS, macOS, watchOS, tvOS, or visionOS application.

## Prerequisites

Before you begin, ensure you have:

1. A RevenueCat account with your app configured
2. Your RevenueCat API key
3. Products configured in App Store Connect and RevenueCat

## Installation

Add ARCPurchasing to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCPurchasing", from: "1.0.0")
]
```

## Configuration

Configure the purchase manager early in your app's lifecycle, typically in your `App` struct:

```swift
import SwiftUI
import ARCPurchasing

@main
struct MyApp: App {

    init() {
        Task {
            try? await configurePurchasing()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configurePurchasing() async throws {
        let config = PurchaseConfiguration(
            apiKey: "your_revenuecat_api_key",
            entitlementIdentifiers: ["premium", "pro"]
        )

        try await ARCPurchaseManager.shared.configure(with: config)
    }
}
```

## Checking Entitlements

Check if a user has access to premium features:

```swift
let hasPremium = await ARCPurchaseManager.shared.hasEntitlement("premium")

if hasPremium {
    // Show premium content
} else {
    // Show upgrade prompt
}
```

## Fetching Products

Fetch available products to display in your paywall:

```swift
let products = try await ARCPurchaseManager.shared.fetchProducts(
    for: ["com.myapp.premium.monthly", "com.myapp.premium.yearly"]
)

for product in products {
    print("\(product.displayName): \(product.displayPrice)")
}
```

## Making a Purchase

Handle the purchase flow:

```swift
func purchase(_ product: PurchaseProduct) async {
    do {
        let result = try await ARCPurchaseManager.shared.purchase(product)

        switch result {
        case .success(let transaction):
            // Purchase successful, unlock content
            print("Purchased \(transaction.productID)")

        case .cancelled:
            // User cancelled, no action needed
            break

        case .pending:
            // Purchase pending approval (e.g., Ask to Buy)
            showPendingMessage()

        case .requiresAction(let message):
            // Payment method needs update
            showActionRequired(message)

        case .unknown:
            // Handle unknown state
            break
        }
    } catch {
        // Handle error
        showError(error)
    }
}
```

## Restoring Purchases

Allow users to restore previous purchases:

```swift
func restorePurchases() async {
    do {
        try await ARCPurchaseManager.shared.restorePurchases()
        // Entitlements will be updated automatically
    } catch {
        showError(error)
    }
}
```

## SwiftUI Integration

ARCPurchaseManager is `@Observable`, making it easy to use in SwiftUI:

```swift
struct PaywallView: View {
    @State private var purchaseManager = ARCPurchaseManager.shared
    @State private var products: [PurchaseProduct] = []

    var body: some View {
        VStack {
            if purchaseManager.isSubscribed {
                Text("Thank you for subscribing!")
            } else {
                ForEach(products) { product in
                    ProductButton(product: product)
                }
            }
        }
        .overlay {
            if purchaseManager.isPurchasing {
                ProgressView()
            }
        }
        .task {
            await loadProducts()
        }
    }

    private func loadProducts() async {
        products = (try? await purchaseManager.fetchProducts(
            for: ["monthly", "yearly"]
        )) ?? []
    }
}
```

## Next Steps

- Learn about custom analytics integration
- Explore the full API reference
- Review testing strategies with mock providers
