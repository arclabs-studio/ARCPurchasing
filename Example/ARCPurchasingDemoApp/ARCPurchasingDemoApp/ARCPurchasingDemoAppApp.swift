//
//  ARCPurchasingDemoAppApp.swift
//  ARCPurchasingDemoApp
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCPurchasing
import SwiftUI

@main
struct ARCPurchasingDemoAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await Self.configurePurchasing()
                }
        }
    }

    private static func configurePurchasing() async {
        // Demo uses the native StoreKit 2 provider — no API key required.
        // Match these identifiers in `Products.storekit` (attach to your
        // scheme via Edit Scheme → Run → Options → StoreKit Configuration).
        let config = PurchaseConfiguration(debugLoggingEnabled: true,
                                           entitlementIdentifiers: ["premium"],
                                           entitlementMapper: { _ in "premium" })

        let provider = StoreKit2ProviderFactory.make(productIDs: ["com.app.premium.monthly",
                                                                  "com.app.premium.yearly",
                                                                  "com.app.premium.lifetime"])

        do {
            try await ARCPurchaseManager.shared.configure(with: config, provider: provider)
            print("ARCPurchasing configured successfully (StoreKit 2)")
        } catch {
            print("Failed to configure ARCPurchasing: \(error)")
        }
    }
}
