//
//  SubscriptionStatusResolverTests.swift
//  ARCPurchasingRevenueCatTests
//
//  Created by ARC Labs Studio on 10/08/2026.
//

import Foundation
import Testing
@testable import ARCPurchasingRevenueCat

struct SubscriptionStatusResolverTests {
    // MARK: Helpers

    private func makeSnapshot(identifier: String = "premium",
                              productIdentifier: String = "com.example.premium.monthly",
                              expirationDate: Date? = Date(timeIntervalSinceNow: 3600),
                              willRenew: Bool = true,
                              billingIssueDetectedAt: Date? = nil) -> ActiveEntitlementSnapshot {
        ActiveEntitlementSnapshot(identifier: identifier,
                                  productIdentifier: productIdentifier,
                                  expirationDate: expirationDate,
                                  willRenew: willRenew,
                                  billingIssueDetectedAt: billingIssueDetectedAt)
    }

    // MARK: Entitlement-derived subscription

    @Test("Promotional entitlement in configured set subscribes without store subscriptions")
    func promotionalEntitlementSubscribes() {
        // Given
        let promo = makeSnapshot(productIdentifier: "rc_promo_premium_lifetime",
                                 expirationDate: Date(timeIntervalSinceNow: 86400),
                                 willRenew: false)

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [promo],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(status.isSubscribed)
        #expect(!status.willRenew)
        #expect(status.activeProductID == "rc_promo_premium_lifetime")
    }

    @Test("Lifetime entitlement with nil expiration subscribes") func lifetimeEntitlementSubscribes() {
        // Given
        let lifetime = makeSnapshot(productIdentifier: "com.example.premium.lifetime",
                                    expirationDate: nil,
                                    willRenew: false)

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [lifetime],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(status.isSubscribed)
        #expect(status.expiresDate == nil)
    }

    @Test("Entitlement outside configured set does not subscribe") func unconfiguredEntitlementDoesNotSubscribe() {
        // Given
        let other = makeSnapshot(identifier: "gold")

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [other],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(!status.isSubscribed)
    }

    // MARK: Legacy behavior (empty configured set)

    @Test("Store subscription subscribes with empty configured set") func storeSubscriptionLegacy() {
        // Given / When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: ["com.example.premium.monthly"],
                                                        activeEntitlements: [makeSnapshot()],
                                                        configuredIdentifiers: [],
                                                        managementURL: nil)

        // Then
        #expect(status.isSubscribed)
        #expect(status.activeProductID == "com.example.premium.monthly")
    }

    @Test("Active entitlement alone does not subscribe with empty configured set")
    func entitlementAloneLegacyDoesNotSubscribe() {
        // Given / When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [makeSnapshot()],
                                                        configuredIdentifiers: [],
                                                        managementURL: nil)

        // Then
        #expect(!status.isSubscribed)
    }

    @Test("No subscriptions and no entitlements is not subscribed") func emptyEverything() {
        // Given / When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(!status.isSubscribed)
        #expect(status.activeProductID == nil)
        #expect(!status.willRenew)
    }

    // MARK: Primary entitlement selection

    @Test("Lifetime entitlement wins over expiring entitlement") func lifetimeWinsSelection() {
        // Given
        let monthly = makeSnapshot(productIdentifier: "com.example.premium.monthly",
                                   expirationDate: Date(timeIntervalSinceNow: 3600))
        let lifetime = makeSnapshot(productIdentifier: "com.example.premium.lifetime",
                                    expirationDate: nil,
                                    willRenew: false)

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [monthly, lifetime],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(status.activeProductID == "com.example.premium.lifetime")
        #expect(status.expiresDate == nil)
    }

    @Test("Configured entitlement preferred over unconfigured for primary selection")
    func configuredPreferredForPrimary() {
        // Given: unconfigured entitlement expires later than configured one
        let configured = makeSnapshot(identifier: "premium",
                                      productIdentifier: "com.example.premium.monthly",
                                      expirationDate: Date(timeIntervalSinceNow: 3600))
        let unconfigured = makeSnapshot(identifier: "gold",
                                        productIdentifier: "com.example.gold.yearly",
                                        expirationDate: Date(timeIntervalSinceNow: 999_999))

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [unconfigured, configured],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(status.activeProductID == "com.example.premium.monthly")
    }

    @Test("Selection is deterministic regardless of input order") func deterministicSelection() {
        // Given
        let expiry = Date(timeIntervalSinceNow: 3600)
        let first = makeSnapshot(identifier: "alpha", productIdentifier: "product.a", expirationDate: expiry)
        let second = makeSnapshot(identifier: "beta", productIdentifier: "product.b", expirationDate: expiry)

        // When
        let forward = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                         activeEntitlements: [first, second],
                                                         configuredIdentifiers: ["alpha", "beta"],
                                                         managementURL: nil)
        let reversed = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                          activeEntitlements: [second, first],
                                                          configuredIdentifiers: ["alpha", "beta"],
                                                          managementURL: nil)

        // Then
        #expect(forward.activeProductID == reversed.activeProductID)
    }

    // MARK: Billing state

    @Test("Billing issue on primary entitlement sets retry and grace flags") func billingIssueFlags() {
        // Given
        let troubled = makeSnapshot(billingIssueDetectedAt: Date())

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: ["com.example.premium.monthly"],
                                                        activeEntitlements: [troubled],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(status.isInBillingRetry)
        #expect(status.isInGracePeriod)
        #expect(status.hasBillingIssues)
    }

    @Test("Healthy entitlement has no billing flags") func healthyEntitlement() {
        // Given / When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [makeSnapshot()],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: nil)

        // Then
        #expect(status.isActiveAndHealthy)
    }

    // MARK: Management URL

    @Test("Management URL passes through") func managementURLPassthrough() throws {
        // Given
        let url = try #require(URL(string: "https://apps.apple.com/account/subscriptions"))

        // When
        let status = SubscriptionStatusResolver.resolve(activeSubscriptions: [],
                                                        activeEntitlements: [makeSnapshot()],
                                                        configuredIdentifiers: ["premium"],
                                                        managementURL: url)

        // Then
        #expect(status.managementURL == url)
    }
}
