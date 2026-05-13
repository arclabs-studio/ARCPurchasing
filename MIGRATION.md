# ARCPurchasing — Migration Guide

## From RevenueCat to StoreKit 2

StoreKit 2 is the recommended path going forward. It removes the RevenueCat SDK dependency, simplifies the build, and uses Apple's first-party APIs for receipts, entitlements, and transaction observation.

### What changes

| Layer | RevenueCat path | StoreKit 2 path |
|-------|-----------------|-----------------|
| Linked products | `ARCPurchasing` + `ARCPurchasingRevenueCat` (+ UI) | `ARCPurchasing` (+ `ARCPurchasingUI`) only |
| `import` lines | `import ARCPurchasingRevenueCat` | none extra |
| `PurchaseConfiguration` | `.init(apiKey:)` | `.init(productIDs:)` |
| `configure()` call | `configure(with: config)` (convenience) | `configure(with: config, provider: StoreKit2ProviderFactory.make())` |
| Customer Center | `ARCCustomerCenterView` (from `ARCPurchasingRevenueCatUI`) | iOS system Settings → Subscriptions (`managementURL` exposed by `SubscriptionStatus`) |
| Receipt validation | RevenueCat dashboard | `PurchaseTransaction.jwsRepresentation` → your backend |
| Entitlement identifiers | RC entitlements (logical names) | Product IDs by default, customisable via `entitlementMapper` closure |

### What does not change

- `ARCPurchaseManager.shared` API — `purchase()`, `restorePurchases()`, `currentEntitlements`, `subscriptionStatus`, etc.
- `ARCPaywallView`, `PaywallConfiguration`, `PaywallTheme`, modifiers.
- Domain models — `PurchaseProduct`, `PurchaseTransaction`, `Entitlement`, `SubscriptionStatus`, `PurchaseResult`, `PurchaseError`.
- `PurchaseAnalytics` protocol + `PurchaseEvent` enum.
- Mocks in `Tests/ARCPurchasingTests/Mocks/`.

### Migration steps

1. **Create `.storekit` configuration**. In Xcode, File → New → File → StoreKit Configuration. Add your products with the same identifiers you used in App Store Connect. Attach it to your scheme so local builds load it.

2. **Map entitlements**. If you previously used a logical entitlement name like `"premium"`, supply an `entitlementMapper` that returns it for every product ID:
   ```swift
   let config = PurchaseConfiguration(
       productIDs: ["com.app.monthly", "com.app.yearly"],
       entitlementIdentifiers: ["premium"],
       entitlementMapper: { _ in "premium" }
   )
   ```
   Skip this if you want entitlement IDs to equal product IDs.

3. **Replace the configure call**.
   ```swift
   // Before
   import ARCPurchasingRevenueCat
   try await ARCPurchaseManager.shared.configure(with: rcConfig)

   // After
   try await ARCPurchaseManager.shared.configure(
       with: sk2Config,
       provider: StoreKit2ProviderFactory.make()
   )
   ```

4. **Drop the RevenueCat product links** from your app target if you no longer need the Customer Center.

5. **Replace `ARCCustomerCenterView` usage**. StoreKit 2 does not ship an equivalent. Either:
   - Link to the system Settings sheet via `subscriptionStatus.managementURL` (`apps.apple.com/account/subscriptions`), or
   - Adopt SwiftUI's `.manageSubscriptionsSheet(isPresented:)` directly in your view.

6. **Wire your backend (optional)**. If/when you stand up a Vapor server, forward `transaction.jwsRepresentation` from `PurchaseResult.success(_:)` to your `/verify-transaction` endpoint. Use the App Store Server Library to call Apple's `VerifyTransaction` endpoint.

7. **Test in the simulator**. StoreKit Configuration files give you instant local purchases — no sandbox account required. Verify subscribe → restore → revoke flows.

### Coexistence

You can leave existing apps on the RevenueCat path indefinitely. Both providers compile against the same `ARCPurchaseManager` API, so callers don't change. New apps should default to StoreKit 2.

### Known gaps in the StoreKit 2 provider (v1)

- **Single subscription group** assumed by `subscriptionStatus()` — picks the first active auto-renewable. If your app has multiple subscription groups, file a feature request.
- **Trial vs. intro distinction** not surfaced — both report `EntitlementPeriodType.intro`.
- **Per-call `appAccountToken` override** not exposed on `purchase()` — set once via `appAccountTokenProvider` at configure time.
- **App Store Server Notifications V2** parsing is intentionally out of scope (handle on your backend).

None of these block production use. Open an issue if any becomes a blocker.
