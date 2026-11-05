# ARCPurchasingDemoApp

Demo application for **ARCPurchasing**.

Configured for the native **StoreKit 2** provider — no API key, no third-party SDK. Runs entirely against a bundled `.storekit` configuration so you can purchase, restore, and inspect entitlements straight from the simulator.

---

## Requirements

- **Xcode**: 16.0+
- **iOS**: 17.0+

No RevenueCat account required.

---

## Running the Example

1. Open `ARCPurchasingDemoApp.xcodeproj` in Xcode.
2. The ARCPurchasing package is already linked from the parent directory (`ARCPurchasing` + `ARCPurchasingUI` products).
3. Attach the bundled `.storekit` configuration (see [StoreKit Setup](#storekit-setup) below).
4. Select a simulator and press **Run** (⌘R).

---

## StoreKit Setup

The demo ships a `Products.storekit` file with three test products that match the IDs configured in the app:

| Product ID | Type | Price |
|------------|------|-------|
| `com.app.premium.monthly` | Auto-renewable subscription | $4.99/month |
| `com.app.premium.yearly` | Auto-renewable subscription | $39.99/year |
| `com.app.premium.lifetime` | Non-consumable | $99.99 |

To activate it for local runs:

1. **Product → Scheme → Edit Scheme…** (⌘<)
2. Select **Run** in the left sidebar.
3. Open the **Options** tab.
4. Set **StoreKit Configuration** to `Products.storekit`.
5. Close the sheet and run the app.

Once attached, purchases complete instantly without sandbox credentials. Use **Debug → StoreKit → Manage Transactions** to inspect, expire, or refund transactions while running.

---

## Switching to RevenueCat

The demo defaults to StoreKit 2. To run against RevenueCat instead:

1. Link the `ARCPurchasingRevenueCat` product in the app target (File → Add Package Dependencies → ARCPurchasing → ARCPurchasingRevenueCat).
2. Replace the `configurePurchasing()` body in `ARCPurchasingDemoAppApp.swift`:
   ```swift
   import ARCPurchasingRevenueCat

   let config = PurchaseConfiguration(
       apiKey: "your_revenuecat_api_key_here",
       debugLoggingEnabled: true,
       entitlementIdentifiers: ["premium"]
   )
   try await ARCPurchaseManager.shared.configure(with: config)
   ```
3. Configure your products in the RevenueCat dashboard with matching identifiers.

---

## Features Demonstrated

### ContentView

- **Subscription Status**: Configured + subscribed flags, active product ID, expiration, auto-renewal
- **Active Entitlements**: List of active entitlements with period type and renewal state
- **Restore Purchases**: Triggers `AppStore.sync()` via the manager
- **Refresh State**: Manually re-queries entitlements

### PaywallView (DemoPaywallScreen)

- `ARCPaywallView` with two theme presets (Dark Burgundy, Light Gold)
- Loading states, error handling, and restore button built into the paywall
- Uses `previewProducts` for instant visual rendering — switch to live products by removing that parameter

---

## Architecture

```
ARCPurchasingDemoApp/
├── ARCPurchasingDemoApp.xcodeproj
├── ARCPurchasingDemoApp/
│   ├── ARCPurchasingDemoAppApp.swift   # App entry, StoreKit 2 configuration
│   ├── ContentView.swift                # Status + entitlement display
│   ├── PaywallView.swift                # ARCPaywallView demo with theme picker
│   ├── Products.storekit                # Bundled test products
│   └── Assets.xcassets
└── README.md
```

### Key Patterns

- **@State with ARCPurchaseManager.shared** — observe the `@Observable` singleton directly
- **async/await** — all purchase operations use Swift concurrency
- **Provider injection** — configure() takes an explicit `PurchaseProviding` factory output, making the active backend visible at the call site

---

## Troubleshooting

### "No products found"

- Confirm the `.storekit` file is set in the scheme's Run → Options
- Verify product IDs match those passed to `PurchaseConfiguration(productIDs:)`
- If using sandbox, ensure you are signed into a sandbox account on the device

### "Provider not configured"

- `configure()` runs in a `.task` modifier — give it a beat before invoking purchase actions
- Check Xcode console for the configuration error message

### Build errors with package

- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Reset package caches: **File → Packages → Reset Package Caches**

---

## License

PolyForm Noncommercial 1.0.0 — see [LICENSE](../../LICENSE).

---

**[ARC Labs Studio](https://github.com/arclabs-studio)** | Made with care
