//
//  StoreKit2ProviderTests.swift
//  ARCPurchasingTests
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import Foundation
import Testing
@testable import ARCPurchasing

// MARK: - Configuration

struct StoreKit2ProviderConfigurationTests {
    @Test("isConfigured is false before configure()") func unconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])
        let configured = await provider.isConfigured
        #expect(configured == false)
    }

    @Test("configure() sets isConfigured") func configured() async throws {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])

        try await provider.configure(with: PurchaseConfiguration())

        let configured = await provider.isConfigured
        #expect(configured == true)
    }

    @Test("Empty productIDs throws invalidConfiguration") func emptyProductIDs() async {
        let provider = StoreKit2Provider(productIDs: [])

        await #expect(throws: PurchaseError.self) {
            try await provider.configure(with: PurchaseConfiguration())
        }
    }
}

// MARK: - Unconfigured Guards

struct StoreKit2ProviderUnconfiguredGuardsTests {
    @Test("fetchProducts throws when unconfigured") func fetchProductsUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])

        await #expect(throws: PurchaseError.self) {
            _ = try await provider.fetchProducts(for: ["com.test.monthly"])
        }
    }

    @Test("fetchOfferings throws when unconfigured") func fetchOfferingsUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])

        await #expect(throws: PurchaseError.self) {
            _ = try await provider.fetchOfferings()
        }
    }

    @Test("hasEntitlement returns false when unconfigured") func hasEntitlementUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])
        let result = await provider.hasEntitlement("premium")
        #expect(result == false)
    }

    @Test("currentEntitlements returns empty when unconfigured") func currentEntitlementsUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])
        let result = await provider.currentEntitlements()
        #expect(result.isEmpty)
    }

    @Test("subscriptionStatus returns nil when unconfigured") func subscriptionStatusUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])
        let result = await provider.subscriptionStatus()
        #expect(result == nil)
    }

    @Test("purchase throws when unconfigured") func purchaseUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])
        let dummy = PurchaseProduct(id: "com.test.monthly",
                                    displayName: "Test",
                                    description: "Test product",
                                    price: 4.99,
                                    displayPrice: "$4.99",
                                    currencyCode: "USD",
                                    type: .autoRenewableSubscription)

        await #expect(throws: PurchaseError.self) {
            _ = try await provider.purchase(dummy)
        }
    }

    @Test("restorePurchases throws when unconfigured") func restoreUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])

        await #expect(throws: PurchaseError.self) {
            try await provider.restorePurchases()
        }
    }

    @Test("syncPurchases throws when unconfigured") func syncUnconfigured() async {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])

        await #expect(throws: PurchaseError.self) {
            try await provider.syncPurchases()
        }
    }

    @Test("purchase throws productNotFound when underlyingProduct is not native Product") func wrongUnderlyingProduct() async throws {
        let provider = StoreKit2Provider(productIDs: ["com.test.monthly"])
        try await provider.configure(with: PurchaseConfiguration())

        let mockProduct = PurchaseProduct(id: "com.test.monthly",
                                          displayName: "Test",
                                          description: "Test product",
                                          price: 4.99,
                                          displayPrice: "$4.99",
                                          currencyCode: "USD",
                                          type: .autoRenewableSubscription)

        await #expect(throws: PurchaseError.productNotFound("com.test.monthly")) {
            _ = try await provider.purchase(mockProduct)
        }
    }
}

// MARK: - Factory

struct StoreKit2ProviderFactoryTests {
    @Test("factory returns an unconfigured provider") func factoryMake() async {
        let provider = StoreKit2ProviderFactory.make(productIDs: ["com.test.monthly"])
        let configured = await provider.isConfigured
        #expect(configured == false)
    }
}
