# 💳 ARCPurchasing

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**In-App Purchase management for ARC Labs Studio apps**

Protocol-based | RevenueCat powered | Analytics ready | Swift 6 compliant

---

## Overview

ARCPurchasing provides a unified, protocol-based interface for managing in-app purchases across all ARC Labs Studio applications. Built on RevenueCat with a clean abstraction layer, it enables easy provider switching while maintaining consistent APIs.

### Key Features

- **Protocol-based abstraction** - Clean separation between interface and implementation
- **RevenueCat integration** - Production-ready with full feature support
- **Analytics events** - Track purchase funnel with custom or built-in analytics
- **Swift 6 compliant** - Strict concurrency with Sendable types
- **Full test coverage** - Comprehensive mocks for testing

---

## Requirements

- **Swift:** 6.0+
- **Platforms:** iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+ / visionOS 1.0+
- **Xcode:** 16.0+
- **Dependencies:** RevenueCat SDK 5.0+, ARCLogger

---

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCPurchasing", from: "1.0.0")
]
```

Or in Xcode: File > Add Package Dependencies and enter the repository URL.

---

## Usage

### Quick Start

```swift
import ARCPurchasing

// Configure on app launch
let config = PurchaseConfiguration(
    apiKey: "your_revenuecat_api_key",
    entitlementIdentifiers: ["premium"]
)

try await ARCPurchaseManager.shared.configure(with: config)

// Check entitlement
let hasPremium = await ARCPurchaseManager.shared.hasEntitlement("premium")

// Fetch and purchase a product
let products = try await ARCPurchaseManager.shared.fetchProducts(for: ["com.app.premium_monthly"])
if let product = products.first {
    let result = try await ARCPurchaseManager.shared.purchase(product)

    switch result {
    case .success(let transaction):
        print("Purchased: \(transaction.productID)")
    case .cancelled:
        print("User cancelled")
    case .pending:
        print("Awaiting approval")
    default:
        break
    }
}
```

### SwiftUI Integration

```swift
import SwiftUI
import ARCPurchasing

struct SubscriptionView: View {
    @State private var purchaseManager = ARCPurchaseManager.shared
    @State private var products: [PurchaseProduct] = []

    var body: some View {
        VStack {
            if purchaseManager.subscriptionStatus?.isSubscribed == true {
                Text("You're subscribed!")
            } else {
                ForEach(products) { product in
                    Button("\(product.displayName) - \(product.displayPrice)") {
                        Task {
                            _ = try await purchaseManager.purchase(product)
                        }
                    }
                    .disabled(purchaseManager.isPurchasing)
                }
            }
        }
        .task {
            products = (try? await purchaseManager.fetchProducts(
                for: ["com.app.premium_monthly", "com.app.premium_yearly"]
            )) ?? []
        }
    }
}
```

### Custom Analytics

```swift
import ARCPurchasing

final class FirebasePurchaseAnalytics: PurchaseAnalytics {
    func track(_ event: PurchaseEvent) async {
        switch event {
        case .purchaseCompleted(let productID, let price, let currency, let transactionID):
            // Track to Firebase, Amplitude, etc.
            Analytics.logEvent("purchase", parameters: [
                "product_id": productID,
                "price": price,
                "currency": currency
            ])
        default:
            Analytics.logEvent(event.name, parameters: nil)
        }
    }
}

// Use custom analytics
try await ARCPurchaseManager.shared.configure(
    with: config,
    analytics: FirebasePurchaseAnalytics()
)
```

---

## Architecture

```
ARCPurchasing/
├── Core/           # Manager and configuration
├── Protocols/      # Abstraction layer
├── Models/         # Domain models
├── Providers/      # Implementation (RevenueCat)
└── Analytics/      # Event tracking
```

### Protocol Design

The package uses a protocol-oriented design for testability and future provider support:

```swift
// Main protocol composes sub-protocols
protocol PurchaseProviding: ProductProviding, TransactionProviding, EntitlementProviding

// Sub-protocols for specific concerns
protocol ProductProviding     // Fetch products and offerings
protocol TransactionProviding // Purchase and restore
protocol EntitlementProviding // Check entitlements
```

---

## API Reference

### ARCPurchaseManager

The main entry point for all purchase operations.

| Property | Type | Description |
|----------|------|-------------|
| `isConfigured` | `Bool` | Whether the manager is configured |
| `currentEntitlements` | `[Entitlement]` | Active entitlements |
| `subscriptionStatus` | `SubscriptionStatus?` | Current subscription state |
| `isPurchasing` | `Bool` | Whether a purchase is in progress |
| `isRestoring` | `Bool` | Whether a restore is in progress |

| Method | Description |
|--------|-------------|
| `configure(with:analytics:)` | Initialize with configuration |
| `fetchProducts(for:)` | Fetch products by identifiers |
| `fetchOfferings()` | Fetch all offerings |
| `purchase(_:)` | Purchase a product |
| `restorePurchases()` | Restore previous purchases |
| `hasEntitlement(_:)` | Check for specific entitlement |
| `identify(userID:)` | Identify the current user |
| `logOut()` | Log out current user |

### PurchaseResult

Represents the outcome of a purchase operation:

- `.success(PurchaseTransaction)` - Purchase completed
- `.cancelled` - User cancelled
- `.pending` - Awaiting approval
- `.requiresAction(String)` - Action needed
- `.unknown` - Unknown result

### PurchaseError

Domain errors for purchase operations:

- `.notConfigured` - Provider not configured
- `.invalidAPIKey` - Invalid API key
- `.productNotFound(String)` - Product not found
- `.purchaseFailed(String)` - Purchase failed
- `.userCancelled` - User cancelled
- `.networkError(String)` - Network error
- `.timeout` - Request timeout

---

## Testing

The package includes comprehensive mocks for testing:

```swift
import Testing
@testable import ARCPurchasing

@Suite("Purchase Tests")
struct PurchaseTests {

    @Test("Purchase completes successfully")
    func purchaseCompletes() async throws {
        let mockProvider = MockPurchaseProvider()
        mockProvider.purchaseResult = .success(PurchaseTransaction.mock())

        let product = PurchaseProduct.mock()
        let result = try await mockProvider.purchase(product)

        #expect(result.isSuccess)
        #expect(mockProvider.purchaseCalled)
    }
}
```

---

## Example App

See `Example/ARCPurchasingDemoApp/` for a standalone demo Xcode project demonstrating:

- Product fetching and display
- Purchase flow with loading states
- Entitlement checking
- Subscription status display
- Restore purchases

Follow the setup instructions in the [Example README](Example/ARCPurchasingDemoApp/README.md).

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

**[ARC Labs Studio](https://github.com/arclabs-studio)** | Made with care

</div>
