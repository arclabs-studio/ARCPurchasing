//
//  StoreKit2ManagerIntegrationTests.swift
//  ARCPurchasingTests
//
//  Created by ARC Labs Studio on 13/05/2026.
//
//  Smoke tests that exercise `ARCPurchaseManager` end-to-end with the
//  `StoreKit2Provider`. SKTestSession-driven purchase flows are deferred
//  to the consuming app (`Example/`) because StoreKit 2 product lookups
//  require a hosting bundle that `swift test` does not provide.
//

import Foundation
import Testing
@testable import ARCPurchasing

@MainActor
struct StoreKit2ManagerIntegrationTests {
    @Test("Configuring manager with StoreKit2 provider succeeds") func configureSucceeds() async throws {
        let manager = ARCPurchaseManager()
        let provider = StoreKit2ProviderFactory.make(productIDs: ["com.test.monthly", "com.test.yearly"])
        let config = PurchaseConfiguration(entitlementIdentifiers: ["premium"])

        try await manager.configure(with: config, provider: provider)

        #expect(manager.isConfigured == true)
        #expect(manager.isSubscribed == false)
        #expect(manager.currentEntitlements.isEmpty)
    }

    @Test("Manager rejects empty productIDs") func sk2RejectsEmptyProductIDs() async {
        let manager = ARCPurchaseManager()
        let provider = StoreKit2ProviderFactory.make(productIDs: [])

        await #expect(throws: PurchaseError.self) {
            try await manager.configure(with: PurchaseConfiguration(), provider: provider)
        }
    }

    @Test("Manager honours entitlementMapper closure") func entitlementMapperWired() async throws {
        let manager = ARCPurchaseManager()
        let provider = StoreKit2ProviderFactory.make(productIDs: ["com.test.monthly", "com.test.yearly"])
        let config = PurchaseConfiguration(entitlementIdentifiers: ["premium"],
                                           entitlementMapper: { _ in "premium" })

        try await manager.configure(with: config, provider: provider)

        // No active transactions in unit-test env — just confirm wiring did
        // not throw and the manager reports empty entitlements rather than
        // crashing.
        #expect(manager.currentEntitlements.isEmpty)
    }

    @Test("Manager exposes hard-coded SK2 management URL when no active sub") func sk2ManagementURL() async throws {
        let manager = ARCPurchaseManager()
        let provider = StoreKit2ProviderFactory.make(productIDs: ["com.test.monthly"])

        try await manager.configure(with: PurchaseConfiguration(), provider: provider)

        let expected = URL(string: "https://apps.apple.com/account/subscriptions")
        #expect(manager.subscriptionStatus?.managementURL == expected)
    }
}
