# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-20

First public release of **ARCPurchasing**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (0.1.0 → 1.2.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

### Changed

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [1.2.0] - 2026-08-10

#### Fixed

- `SubscriptionStatus.isSubscribed` now derives from the configured
  `PurchaseConfiguration.entitlementIdentifiers` in addition to store
  subscriptions. Promotional entitlements granted from the RevenueCat
  dashboard and lifetime (non-consumable) purchases now unlock
  subscription state. Empty `entitlementIdentifiers` preserves the
  legacy subscriptions-only behavior.
- Primary entitlement selection is now deterministic (latest expiration
  wins; non-expiring lifetime entitlements sort first), replacing the
  previous arbitrary `entitlements.active.values.first` pick.

---

### [1.0.0] - 2025-01-23

#### Added

- Initial release of ARCPurchasing
- Protocol-based architecture with `PurchaseProviding`, `ProductProviding`, `TransactionProviding`, and `EntitlementProviding`
- RevenueCat provider implementation
- Domain models: `PurchaseProduct`, `PurchaseTransaction`, `Entitlement`, `SubscriptionStatus`, `PurchaseResult`, `PurchaseError`
- `ARCPurchaseManager` facade with SwiftUI integration via `@Observable`
- Analytics system with `PurchaseEvent` and `PurchaseAnalytics` protocol
- Default analytics implementation using ARCLogger
- Comprehensive test suite with mocks and test helpers
- DocC documentation

#### Technical

- Swift 6.0 with strict concurrency
- Platforms: iOS 17.0+, macOS 14.0+, watchOS 10.0+, tvOS 17.0+, visionOS 1.0+
- Dependencies: RevenueCat 5.0+, ARCLogger 1.0+

---

[1.0.0]: https://github.com/arclabs-studio/ARCPurchasing/releases/tag/v1.0.0
