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
        // Replace with your RevenueCat API key
        let config = PurchaseConfiguration(
            apiKey: "your_revenuecat_api_key_here",
            debugLoggingEnabled: true,
            storeKitVersion: .storeKit2,
            entitlementIdentifiers: ["premium", "pro"]
        )

        do {
            try await ARCPurchaseManager.shared.configure(with: config)
            print("ARCPurchasing configured successfully")
        } catch {
            print("Failed to configure ARCPurchasing: \(error)")
        }
    }
}
