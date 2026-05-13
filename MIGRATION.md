# ARCPurchasing — Migration Guide

## Provider Agnosticism (v1)

The package is fully provider-agnostic: the shared `PurchaseConfiguration` carries only cross-backend knobs, and each provider owns its own configuration through its factory. Adding a new backend (Adapty, Glassfy, in-house) means writing a new `PurchaseProviding` conformance and a factory — no changes to the shared API surface.

### What changes for callers

| Layer | Before (early SK2 drop) | Now (agnostic) |
|-------|------------------------|----------------|
| Shared config | `PurchaseConfiguration(apiKey:)` or `PurchaseConfiguration(productIDs:)` | `PurchaseConfiguration(userID:debugLoggingEnabled:entitlementIdentifiers:entitlementMapper:)` |
| Backend config | Embedded in `PurchaseConfiguration` | On the provider factory call |
| RC configure | `configure(with: PurchaseConfiguration(apiKey: ...))` | `configure(with: config, provider: RevenueCatProviderFactory.make(apiKey: ...))` |
| SK2 configure | `configure(with: PurchaseConfiguration(productIDs: ...), provider: StoreKit2ProviderFactory.make())` | `configure(with: config, provider: StoreKit2ProviderFactory.make(productIDs: ...))` |
| Validation error | `PurchaseError.invalidAPIKey` | `PurchaseError.invalidConfiguration(String)` |
| `StoreKitVersion` | Lived in core | Lives in `ARCPurchasingRevenueCat` (it is an RC-only knob) |

### From RevenueCat to StoreKit 2

1. **Add the StoreKit configuration**. In Xcode, File → New → File → StoreKit Configuration. Add your products with the same identifiers you used in App Store Connect. Attach it to your scheme.

2. **Swap the factory at the configure call site**:
   ```swift
   // Before
   let config = PurchaseConfiguration(entitlementIdentifiers: ["premium"])
   try await ARCPurchaseManager.shared.configure(
       with: config,
       provider: RevenueCatProviderFactory.make(apiKey: "rc_xxx")
   )

   // After
   let config = PurchaseConfiguration(
       entitlementIdentifiers: ["premium"],
       entitlementMapper: { _ in "premium" }
   )
   try await ARCPurchaseManager.shared.configure(
       with: config,
       provider: StoreKit2ProviderFactory.make(
           productIDs: ["com.app.monthly", "com.app.yearly"]
       )
   )
   ```

3. **Drop the RevenueCat product links** from your app target if you no longer need the Customer Center (`ARCPurchasingRevenueCatUI`).

4. **Replace `ARCCustomerCenterView` usage**. StoreKit 2 does not ship an equivalent. Either:
   - Link to the system Settings sheet via `subscriptionStatus.managementURL` (`apps.apple.com/account/subscriptions`), or
   - Adopt SwiftUI's `.manageSubscriptionsSheet(isPresented:)` directly in your view.

5. **Wire your backend (optional)**. If/when you stand up a Vapor server, forward `transaction.jwsRepresentation` from `PurchaseResult.success(_:)` to your `/verify-transaction` endpoint. Use the App Store Server Library to call Apple's `VerifyTransaction` endpoint.

6. **Test in the simulator**. StoreKit Configuration files give you instant local purchases — no sandbox account required.

### Known gaps in the StoreKit 2 provider (v1)

- **Single subscription group** assumed by `subscriptionStatus()` — picks the first active auto-renewable. File a feature request if you need multi-group.
- **Trial vs. intro distinction** not surfaced — both report `EntitlementPeriodType.intro`.
- **Per-call `appAccountToken` override** not exposed on `purchase()` — set once via the factory's `appAccountTokenProvider`.
- **App Store Server Notifications V2** parsing is intentionally out of scope (handle on your backend).

None of these block production use. Open an issue if any becomes a blocker.
