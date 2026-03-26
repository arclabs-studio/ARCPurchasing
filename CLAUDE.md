# ARCPurchasing — Agent Guide

Protocol-based in-app purchase management for ARC Labs apps, powered by RevenueCat.

---

## Two Modules

| Module | Import | Purpose |
|--------|--------|---------|
| `ARCPurchasing` | Core logic | `ARCPurchaseManager`, protocols, models, RevenueCat provider |
| `ARCPurchasingUI` | SwiftUI views | `ARCPaywallView` (fully custom), `PaywallConfiguration`, `PaywallTheme`, paywall modifiers |

**Rule**: Only `ARCPurchasingUI` may expose RevenueCat types (e.g., `Offering`). The core `ARCPurchasing` module must never leak RevenueCat types in its public API.

---

## Architecture

```
ARCPurchaseManager (Core/ARCPurchaseManager.swift)
    ↕ conforms to
PurchaseProviding (Protocols/)
    composed of: ProductProviding, TransactionProviding, EntitlementProviding
    implemented by:
RevenueCatProvider (Providers/RevenueCat/)
```

- `ARCPurchaseManager` is the entry point — `@MainActor @Observable` singleton
- All purchase logic goes through protocols; `RevenueCatProvider` is the only implementation
- `PurchaseAnalytics` protocol is injected at configure time

---

## Key Files

| File | Purpose |
|------|---------|
| `Sources/ARCPurchasing/Core/ARCPurchaseManager.swift` | Entry point, observable state |
| `Sources/ARCPurchasing/Core/PurchaseConfiguration.swift` | Configuration struct |
| `Sources/ARCPurchasing/Protocols/PurchaseProviding.swift` | Main protocol |
| `Sources/ARCPurchasingUI/Configuration/PaywallConfiguration.swift` | Paywall content config (copy, features, product IDs, URLs) |
| `Sources/ARCPurchasingUI/Configuration/PaywallTheme.swift` | Visual theme (colors, `.darkBurgundy`, `.lightGold`) |
| `Sources/ARCPurchasingUI/Views/ARCPaywallView.swift` | Primary paywall view — fully custom SwiftUI, no RevenueCatUI |
| `Sources/ARCPurchasingUI/Views/Paywall/` | Internal subviews (header, features, product cards, footer) |
| `Sources/ARCPurchasingUI/ViewModifiers/PaywallModifiers.swift` | `.presentARCPaywall`, `.presentARCPaywallIfNeeded` |
| `Tests/ARCPurchasingTests/Mocks/MockAnalytics.swift` | Mock for testing |

---

## Dependencies

- `purchases-ios` (RevenueCat SDK 5.0+) — both targets depend on this
- `ARCLogger` — logging only, no business logic coupling
- `RevenueCatUI` — ARCPurchasingUI only

---

## Testing

- Use `MockPurchaseProvider` (in test target) to test without RevenueCat
- All test files use Swift Testing framework (`import Testing`, `@Test`, `#expect`)
- No XCTest — Swift Testing only

---

## Critical Rules

1. **Never expose RevenueCat types from `ARCPurchasing` module** — only from `ARCPurchasingUI`
2. **All public APIs must be protocol-backed** — no concrete RevenueCat types in public interfaces
3. **Swift 6 strict concurrency** — all new code must compile with strict concurrency enabled
4. **`ARCPurchaseManager` is the only entry point** — do not expose `RevenueCatProvider` directly

---

## Cross-App Monetization Patterns

For architectural integration patterns, paywall design, pricing strategy, and RevenueCat tooling, see:

```
ARCDevTools/ARCKnowledge/Monetization/
├── paywall-patterns.md      ← High-conversion paywall design
├── pricing-strategy.md      ← Business model and localization
├── integration-guide.md     ← Clean Architecture integration
└── tools-references.md      ← RevenueCat dashboard and analytics
```
