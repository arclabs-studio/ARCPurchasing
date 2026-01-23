# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-23

### Added

- Initial release of ARCPurchasing
- Protocol-based architecture with `PurchaseProviding`, `ProductProviding`, `TransactionProviding`, and `EntitlementProviding`
- RevenueCat provider implementation
- Domain models: `PurchaseProduct`, `PurchaseTransaction`, `Entitlement`, `SubscriptionStatus`, `PurchaseResult`, `PurchaseError`
- `ARCPurchaseManager` facade with SwiftUI integration via `@Observable`
- Analytics system with `PurchaseEvent` and `PurchaseAnalytics` protocol
- Default analytics implementation using ARCLogger
- Comprehensive test suite with mocks and test helpers
- DocC documentation

### Technical

- Swift 6.0 with strict concurrency
- Platforms: iOS 17.0+, macOS 14.0+, watchOS 10.0+, tvOS 17.0+, visionOS 1.0+
- Dependencies: RevenueCat 5.0+, ARCLogger 1.0+

[Unreleased]: https://github.com/arclabs-studio/ARCPurchasing/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/arclabs-studio/ARCPurchasing/releases/tag/v1.0.0
