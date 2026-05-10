# 💳 ARCPurchasing

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS-blue.svg)
![License](https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange.svg)
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

### SwiftUI Paywall

`ARCPurchasingUI` provides a fully custom, configurable paywall — no RevenueCat dashboard required.

```swift
import ARCPurchasingUI

// Present as a sheet
.presentARCPaywall(
    isPresented: $showPaywall,
    configuration: PaywallConfiguration(
        headerLabel: "MY APP PREMIUM",
        title: "Unlock the full\nexperience",
        subtitle: "Everything you need, nothing you don't",
        iconName: "star.circle.fill",
        features: [
            .init(highlightedText: "Unlimited access",
                  description: "to all premium features"),
            .init(highlightedText: "No ads",
                  description: "clean, distraction-free experience"),
        ],
        highlightedProductID: "com.app.premium.yearly",
        lifetimeProductID: "com.app.premium.lifetime",
        lifetimeSubtitle: "One-time purchase · Limited offer",
        ctaButtonTitle: "Start Premium",
        termsOfServiceURL: tosURL,
        privacyPolicyURL: privacyURL
    ),
    theme: .darkBurgundy   // or .lightGold, or a custom PaywallTheme
)

// Auto-present only when user lacks the entitlement
.presentARCPaywallIfNeeded(
    entitlement: "premium",
    configuration: config,
    theme: .darkBurgundy
)

// Embed directly
ARCPaywallView(configuration: config, theme: .lightGold)
```

#### Themes

Two built-in theme presets match the reference designs:

| Preset | Background | Accents |
|--------|-----------|---------|
| `.darkBurgundy` | Deep burgundy (#541311) | Gold |
| `.lightGold` | Warm gold | Dark burgundy |

Build a custom theme by constructing `PaywallTheme` directly and passing any `Color` values you need.

#### Xcode Previews and Demo Apps

Pass `previewProducts` to render the paywall without a RevenueCat connection:

```swift
ARCPaywallView(
    configuration: config,
    theme: .darkBurgundy,
    previewProducts: ARCPaywallView.previewMockProducts  // built-in mock products
)
```

#### Features

- Savings badges auto-calculated ("SAVE 42%") from monthly price baseline
- Lifetime product rendered as a separate full-width dashed card
- Restore Purchases, Terms, Privacy links built in (App Store requirement)
- Analytics tracked automatically via `PurchaseEvent`

---

### SwiftUI Integration (manual)

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

## ✅ Best Practices

### Configuration

- **Configure early**: Call `ARCPurchaseManager.shared.configure(with:)` in `App.init`, before any view appears.
- **Separate API keys by environment**: Use xcconfig files or build configurations to inject the RevenueCat API key. Never hardcode it in source.
- **Debug logging**: Enable `debugLoggingEnabled` only in DEBUG builds — it logs sensitive purchase data.

```swift
@main
struct MyApp: App {
    init() {
        Task {
            let config = PurchaseConfiguration(
                apiKey: Bundle.main.infoDictionary?["RC_API_KEY"] as? String ?? ""
            )
            try await ARCPurchaseManager.shared.configure(with: config)
        }
    }
}
```

### Entitlement Design

- **Use a single `"premium"` entitlement** rather than per-feature entitlements. This keeps entitlement checking simple and makes it easy to restructure which features are included in premium tiers without changing code.
- Define the entitlement identifier as a constant in your app to avoid typos.

### Error Handling

- **Handle all `PurchaseResult` cases**: `.success`, `.cancelled`, `.pending`, `.requiresAction`, and `.unknown`.
- Show user-friendly messages for `PurchaseError` — use the built-in `localizedDescription` and `recoverySuggestion`.
- Track purchase failures via `PurchaseAnalytics` to identify systemic issues.

### UI

- **Always include a Restore Purchases button** — it is required by App Store Review Guidelines §3.1.1. `ARCPaywallView` includes this automatically.
- Show loading states while `isPurchasing` or `isRestoring` is `true` — disable purchase buttons to prevent duplicate taps.
- Use `ARCPaywallView` with `PaywallConfiguration` and `PaywallTheme` for a fully custom, code-driven paywall. Pass `previewProducts` for Xcode Previews and demo builds.
- Use `.presentARCPaywallIfNeeded(entitlement:configuration:)` as a single-line entitlement gate on any view.

### Security

- API keys belong in xcconfig, not source code.
- Validate entitlements server-side for high-value content.
- Do not cache entitlement state locally beyond the session — always call `hasEntitlement(_:)` which reflects the live RevenueCat state.

---

## 📋 App Revenue Checklist

Use this checklist before submitting a new app or adding IAP to an existing one.

### Pre-Development
- [ ] App Store Connect products created (subscriptions, consumables, or non-consumables)
- [ ] Products in "Ready to Submit" state in App Store Connect
- [ ] RevenueCat project configured with entitlements and offerings
- [ ] Entitlement identifier agreed upon and documented

### Implementation
- [ ] `ARCPurchaseManager.configure()` called in `App.init` before any view appears
- [ ] RevenueCat API key stored in xcconfig (not hardcoded)
- [ ] All `PurchaseResult` cases handled in the purchase flow
- [ ] Restore Purchases accessible from paywall and/or Settings
- [ ] Loading state shown while `isPurchasing == true`
- [ ] Error messages user-friendly (use `PurchaseError.recoverySuggestion`)
- [ ] `PurchaseAnalytics` implementation wired to your analytics provider
- [ ] Unit tests written using `MockPurchaseProvider`

### Pre-Launch
- [ ] Full purchase flow tested in sandbox on device (not just simulator)
- [ ] Restore flow tested in sandbox
- [ ] App Store screenshot for IAP submitted to App Store Connect (if required)
- [ ] Auto-renewal disclosure visible on paywall
- [ ] Restore Purchases button visible on paywall
- [ ] Terms of Service and Privacy Policy links on paywall
- [ ] App Store Review Guidelines §3.1 compliance verified
- [ ] Localized pricing reviewed for key markets (US, EU, JP, BR, IN)

### Post-Launch
- [ ] RevenueCat Dashboard monitored for first 7 days post-launch
- [ ] Trial-to-paid conversion baseline measured
- [ ] Churn rate monitored weekly
- [ ] First A/B test for pricing or paywall copy planned

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

## 📄 License

**PolyForm Noncommercial License 1.0.0** © 2025–2026 ARC Labs Studio.

Source-available. Free for non-commercial use (research, study, hobby, evaluation). **Commercial use requires a separate license** — contact `arclabs.studio@gmail.com`.

ARC Labs Studio's own commercial products are covered by an internal use grant — see [INTERNAL-USE.md](INTERNAL-USE.md).

See [LICENSE](LICENSE) for the full license text.

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request on GitHub.

---

<div align="center">

**[ARC Labs Studio](https://github.com/arclabs-studio)** | Made with care

</div>
