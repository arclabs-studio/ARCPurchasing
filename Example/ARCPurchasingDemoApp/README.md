# ARCPurchasingDemoApp

Demo application for **ARCPurchasing** package.

This app demonstrates the full integration of ARCPurchasing, including product fetching, purchasing, entitlement checking, and subscription status management.

---

## Requirements

- **Xcode**: 16.0+
- **iOS**: 17.0+
- **RevenueCat Account**: You'll need a RevenueCat API key

---

## Running the Example

1. Open `ARCPurchasingDemoApp.xcodeproj` in Xcode
2. The ARCPurchasing package is already linked from the parent directory
3. Configure your RevenueCat API key (see below)
4. Select a simulator and press **Run** (⌘R)

---

## Configuration

### 1. RevenueCat API Key

Open `ARCPurchasingDemoApp/ARCPurchasingDemoAppApp.swift` and replace the API key:

```swift
let config = PurchaseConfiguration(
    apiKey: "your_revenuecat_api_key_here",  // Replace this
    debugLoggingEnabled: true,
    storeKitVersion: .storeKit2,
    entitlementIdentifiers: ["premium", "pro"]
)
```

### 2. Product IDs

Open `ARCPurchasingDemoApp/PaywallView.swift` and update the product IDs to match your App Store Connect configuration:

```swift
private let productIDs: Set<String> = [
    "com.yourcompany.yourapp.premium.monthly",
    "com.yourcompany.yourapp.premium.yearly"
]
```

---

## Features Demonstrated

### ContentView

- **Subscription Status**: Shows if the user is configured and subscribed
- **Active Entitlements**: Lists all active entitlements with details (period type, renewal status)
- **Restore Purchases**: Restores previous purchases from the App Store
- **Refresh State**: Manually refreshes entitlement state from RevenueCat

### PaywallView

- **Product Fetching**: Loads products from RevenueCat with loading states
- **Product Display**: Shows product name, description, price, and subscription period
- **Purchase Flow**: Handles the complete purchase flow with feedback
- **Error Handling**: Displays errors and allows retry
- **Restore Purchases**: Quick access to restore from paywall

---

## Architecture

The demo follows ARC Labs standards:

```
ARCPurchasingDemoApp/
├── ARCPurchasingDemoApp.xcodeproj   # Xcode project
├── ARCPurchasingDemoApp/
│   ├── ARCPurchasingDemoAppApp.swift   # App entry point, configuration
│   ├── ContentView.swift                # Main view, status display
│   ├── PaywallView.swift                # Paywall, purchase flow
│   └── Assets.xcassets                  # App icons and colors
└── README.md
```

### Key Patterns

- **@State with ARCPurchaseManager.shared**: Direct observation of the singleton
- **@Observable**: ARCPurchaseManager uses @Observable for automatic SwiftUI updates
- **async/await**: All purchase operations use Swift concurrency
- **Error handling**: Comprehensive error display with retry options

---

## Testing with StoreKit Configuration

For testing purchases without a real RevenueCat account:

1. In Xcode, go to **File → New → File**
2. Select **StoreKit Configuration File**
3. Add test products matching your `productIDs`
4. In your scheme (**Product → Scheme → Edit Scheme**), select the StoreKit Configuration under **Run → Options**

Note: Some RevenueCat-specific features won't work in StoreKit testing mode.

---

## Troubleshooting

### "No products found"

- Verify your RevenueCat API key is correct
- Check that products are configured in RevenueCat Dashboard
- Ensure product IDs match exactly (case-sensitive)
- Check RevenueCat dashboard for any configuration issues

### "Provider not configured"

- Ensure `configure()` completes before any purchase operations
- Check console for configuration errors
- Verify the API key is valid in RevenueCat dashboard

### Build errors with package

- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Reset package caches: **File → Packages → Reset Package Caches**
- Ensure Xcode 16.0+ is being used

---

## License

MIT License - See [LICENSE](../../LICENSE) for details.

---

**[ARC Labs Studio](https://github.com/arclabs-studio)** | Made with care
