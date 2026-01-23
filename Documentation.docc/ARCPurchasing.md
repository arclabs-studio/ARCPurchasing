# ``ARCPurchasing``

In-App Purchase management for ARC Labs Studio apps.

## Overview

ARCPurchasing provides a unified, protocol-based interface for managing in-app purchases. Built on RevenueCat with a clean abstraction layer, it enables consistent purchase handling across all ARC Labs applications.

### Key Features

- **Protocol-based abstraction** for testability and future provider support
- **RevenueCat integration** with full feature support
- **Analytics events** for tracking purchase funnels
- **Swift 6 compliant** with strict concurrency
- **SwiftUI ready** via `@Observable`

## Getting Started

Configure the purchase manager on app launch:

```swift
import ARCPurchasing

let config = PurchaseConfiguration(
    apiKey: "your_revenuecat_api_key",
    entitlementIdentifiers: ["premium"]
)

try await ARCPurchaseManager.shared.configure(with: config)
```

## Topics

### Essentials

- ``ARCPurchaseManager``
- ``PurchaseConfiguration``

### Products

- ``PurchaseProduct``
- ``ProductType``
- ``SubscriptionPeriod``
- ``IntroductoryOffer``

### Transactions

- ``PurchaseResult``
- ``PurchaseTransaction``

### Entitlements

- ``Entitlement``
- ``EntitlementPeriodType``
- ``SubscriptionStatus``

### Errors

- ``PurchaseError``

### Protocols

- ``PurchaseProviding``
- ``ProductProviding``
- ``TransactionProviding``
- ``EntitlementProviding``

### Analytics

- ``PurchaseAnalytics``
- ``PurchaseEvent``
- ``DefaultPurchaseAnalytics``

### Providers

- ``RevenueCatProvider``
