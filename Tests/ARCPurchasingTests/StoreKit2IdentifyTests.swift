//
//  StoreKit2IdentifyTests.swift
//  ARCPurchasingTests
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import Foundation
import Testing
@testable import ARCPurchasing

// MARK: - Identify / Log Out

struct StoreKit2IdentifyTests {
    @Test("identify with userID derives a stable appAccountToken") func identifySetsToken() async throws {
        let provider = StoreKit2Provider()
        try await provider.configure(with: PurchaseConfiguration(productIDs: ["com.test.monthly"]))

        try await provider.identify(userID: "user-42")
        // We can't read the internal appAccountToken — but identify() must
        // not throw, and the next call should also succeed deterministically.
        try await provider.identify(userID: "user-42")
        try await provider.identify(userID: nil)
        try await provider.identify(userID: "")
    }

    @Test("logOut clears state and re-arms listener") func logOutClears() async throws {
        let provider = StoreKit2Provider()
        try await provider.configure(with: PurchaseConfiguration(productIDs: ["com.test.monthly"]))

        try await provider.identify(userID: "user-99")
        try await provider.logOut()
        // logOut must not throw and provider must remain configured.
        let configured = await provider.isConfigured
        #expect(configured == true)
    }

    @Test("deterministicUUID is stable across calls") func deterministicUUIDStable() {
        let first = StoreKit2Provider.deterministicUUID(from: "user-1")
        let second = StoreKit2Provider.deterministicUUID(from: "user-1")
        #expect(first == second)
    }

    @Test("deterministicUUID is distinct per input") func deterministicUUIDDistinct() {
        let first = StoreKit2Provider.deterministicUUID(from: "user-1")
        let second = StoreKit2Provider.deterministicUUID(from: "user-2")
        #expect(first != second)
    }

    @Test("deterministicUUID respects RFC 4122 v4 shape") func deterministicUUIDShape() {
        let uuid = StoreKit2Provider.deterministicUUID(from: "user-42")
        // RFC 4122: byte 6 high nibble = version (4), byte 8 high two bits = 10 (variant 1)
        let bytes = withUnsafeBytes(of: uuid.uuid) { Array($0) }
        #expect((bytes[6] >> 4) == 4)
        #expect((bytes[8] >> 6) == 2)
    }
}

// MARK: - Subscription Status (sandbox-less)

struct StoreKit2SubscriptionStatusTests {
    @Test("subscriptionStatus returns isSubscribed false with no active transactions") func noActiveSub() async throws {
        let provider = StoreKit2Provider()
        try await provider.configure(with: PurchaseConfiguration(productIDs: ["com.test.monthly"]))

        // In a unit-test environment there are no active StoreKit transactions,
        // so the provider should report no subscription with the universal
        // management URL.
        let status = await provider.subscriptionStatus()
        #expect(status?.isSubscribed == false)
        #expect(status?.managementURL?.absoluteString == "https://apps.apple.com/account/subscriptions")
    }

    @Test("currentEntitlements is empty with no active transactions") func emptyEntitlements() async throws {
        let provider = StoreKit2Provider()
        try await provider.configure(with: PurchaseConfiguration(productIDs: ["com.test.monthly"]))

        let entitlements = await provider.currentEntitlements()
        #expect(entitlements.isEmpty)
    }

    @Test("hasEntitlement returns false with no active transactions") func noEntitlement() async throws {
        let provider = StoreKit2Provider()
        try await provider.configure(with: PurchaseConfiguration(productIDs: ["com.test.monthly"]))

        let result = await provider.hasEntitlement("premium")
        #expect(result == false)
    }
}
