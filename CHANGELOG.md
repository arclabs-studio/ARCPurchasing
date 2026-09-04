# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-09-04

### Fixed

- **`ARCPaywallView` was unusable at accessibility Dynamic Type sizes.** The pinned bottom block (product cards, CTA, footer) did not scroll and had no height bound, so it swelled to nearly the full screen and collapsed the scroll view above it to a sliver — the benefit bullets became unreachable and every label truncated, prices included. The paywall now picks its layout from the environment's Dynamic Type size: standard sizes keep the existing pinned design unchanged, accessibility sizes put header, features, products, CTA and footer in a single scrolling column with the product cards stacked vertically. Prices, period labels, the CTA title and the footer links wrap instead of truncating, the savings badge renders inside its card, and the CTA's fixed 56pt height, the header badge and the feature icons now scale with the content size.
- **Paywall controls were unlabelled for VoiceOver.** The dismiss button was announced as its SF Symbol name, the CTA and Restore button lost their labels whenever they collapsed to a progress indicator, the savings badge was never announced, and no cue told the user which product card was selected. All are now labelled, selection is exposed with the `.isSelected` trait, and the decorative header badge and footer separators are hidden.
- **The paywall's pricing chrome could not be translated.** Period labels (`MONTHLY`, `YEARLY`, `QUARTERLY`, `6 MONTHS`), the per-month line, the monthly-equivalent price and the auto-calculated `SAVE X%` badge were plain `String` values, so they reached SwiftUI's non-localizing `Text` initializer and no consuming app could ever translate them — a Spanish paywall rendered its bullets and CTA in Spanish next to English pricing. They are now `LocalizedStringResource` keys, which resolve against the consuming app's own string catalog like the package's other literals. The keys an app must provide are `MONTHLY`, `YEARLY`, `QUARTERLY`, `6 MONTHS`, `DAY`/`WEEK`/`MONTH`/`YEAR`, `%lld DAYS`/`%lld WEEKS`/`%lld MONTHS`/`%lld YEARS`, `per month`, `%@/month`, `SAVE %lld%%`, `No products available. Please try again later.` and `An unknown error occurred. Please try again.`; English is unchanged when they are absent. Store-supplied text and `badgeOverrides` still render verbatim, and `PaywallConfiguration` is unchanged.

---

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
