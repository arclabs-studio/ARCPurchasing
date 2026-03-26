//
//  ARCPurchaseManagerTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

@MainActor
struct ARCPurchaseManagerTests {
    // MARK: - Configuration Tests

    @Test("Configure sets isConfigured to true") func configure_setsIsConfigured() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()

        // Act
        try await manager.configure(with: .mock(), provider: provider)

        // Assert
        #expect(manager.isConfigured == true)
    }

    @Test("Configure calls provider configure") func configure_callsProviderConfigure() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        let config = PurchaseConfiguration.mock()

        // Act
        try await manager.configure(with: config, provider: provider)

        // Assert
        #expect(provider.configureCalled == true)
        #expect(provider.configureConfig?.apiKey == config.apiKey)
    }

    @Test("Configure refreshes entitlements and subscription state") func configure_refreshesState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.currentEntitlementsResult = [.mock()]
        provider.subscriptionStatusResult = .mock()
        let manager = ARCPurchaseManager()

        // Act
        try await manager.configure(with: .mock(), provider: provider)

        // Assert
        #expect(manager.currentEntitlements.count == 1)
        #expect(manager.subscriptionStatus != nil)
    }

    @Test("Configure uses injected analytics") func configure_usesInjectedAnalytics() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        let manager = ARCPurchaseManager()

        // Act
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        _ = try await manager.purchase(.mock())

        // Assert — analytics received events from the purchase
        #expect(analytics.trackCalled == true)
    }

    // MARK: - Unconfigured Guard Tests

    @Test("fetchProducts throws notConfigured before configure") func fetchProducts_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            _ = try await manager.fetchProducts(for: ["test"])
        }
    }

    @Test("fetchOfferings throws notConfigured before configure") func fetchOfferings_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            _ = try await manager.fetchOfferings()
        }
    }

    @Test("purchase throws notConfigured before configure") func purchase_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            _ = try await manager.purchase(.mock())
        }
    }

    @Test("restorePurchases throws notConfigured before configure") func restorePurchases_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            try await manager.restorePurchases()
        }
    }

    @Test("identify throws notConfigured before configure") func identify_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            try await manager.identify(userID: "user")
        }
    }

    @Test("logOut throws notConfigured before configure") func logOut_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            try await manager.logOut()
        }
    }

    @Test("hasEntitlement returns false before configure") func hasEntitlement_beforeConfigure_returnsFalse() async {
        let manager = ARCPurchaseManager()
        let result = await manager.hasEntitlement("premium")
        #expect(result == false)
    }

    @Test("refreshState does nothing before configure") func refreshState_beforeConfigure_doesNothing() async {
        // Arrange
        let manager = ARCPurchaseManager()

        // Act
        await manager.refreshState()

        // Assert — state unchanged from initial values
        #expect(manager.currentEntitlements.isEmpty)
        #expect(manager.subscriptionStatus == nil)
    }

    // MARK: - Product Tests

    @Test("fetchProducts delegates to provider and returns result") func fetchProducts_delegatesToProvider() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.fetchProductsResult = .success([.mock(id: "product.1"), .mock(id: "product.2")])
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Act
        let products = try await manager.fetchProducts(for: ["product.1", "product.2"])

        // Assert
        #expect(provider.fetchProductsCalled == true)
        #expect(products.count == 2)
    }

    @Test("fetchOfferings delegates to provider and returns result") func fetchOfferings_delegatesToProvider() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.fetchOfferingsResult = .success(["default": [.mock()]])
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Act
        let offerings = try await manager.fetchOfferings()

        // Assert
        #expect(provider.fetchOfferingsCalled == true)
        #expect(offerings["default"]?.count == 1)
    }

    // MARK: - Purchase Flow Tests

    @Test("Purchase success tracks analytics and refreshes state") func purchase_success_tracksAnalyticsAndRefreshesState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        provider.purchaseResult = .success(.mock())
        provider.currentEntitlementsResult = [.mock()]
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()
        provider.currentEntitlementsCalled = false

        // Act
        let result = try await manager.purchase(.mock())

        // Assert
        #expect(result.isSuccess == true)
        #expect(analytics.hasTracked(eventNamed: "purchase_started"))
        #expect(analytics.hasTracked(eventNamed: "purchase_completed"))
        #expect(provider.currentEntitlementsCalled == true)
    }

    @Test("Purchase cancelled tracks analytics") func purchase_cancelled_tracksAnalytics() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        provider.purchaseResult = .cancelled
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()

        // Act
        let result = try await manager.purchase(.mock())

        // Assert
        #expect(result.isCancelled == true)
        #expect(analytics.hasTracked(eventNamed: "purchase_started"))
        #expect(analytics.hasTracked(eventNamed: "purchase_cancelled"))
    }

    @Test("Purchase pending tracks analytics") func purchase_pending_tracksAnalytics() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        provider.purchaseResult = .pending
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()

        // Act
        let result = try await manager.purchase(.mock())

        // Assert
        #expect(result.isPending == true)
        #expect(analytics.hasTracked(eventNamed: "purchase_pending"))
    }

    @Test("Purchase requiresAction tracks failure analytics") func purchase_requiresAction_tracksFailure() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        provider.purchaseResult = .requiresAction("Update payment")
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()

        // Act
        _ = try await manager.purchase(.mock())

        // Assert
        #expect(analytics.hasTracked(eventNamed: "purchase_failed"))
    }

    @Test("Purchase unknown tracks failure analytics") func purchase_unknown_tracksFailure() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        provider.purchaseResult = .unknown
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()

        // Act
        _ = try await manager.purchase(.mock())

        // Assert
        #expect(analytics.hasTracked(eventNamed: "purchase_failed"))
    }

    @Test("isPurchasing is false after purchase completes") func purchase_isPurchasingResetAfterCompletion() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.purchaseResult = .success(.mock())
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Act
        _ = try await manager.purchase(.mock())

        // Assert
        #expect(manager.isPurchasing == false)
    }

    // MARK: - Restore Tests

    @Test("Restore delegates to provider, tracks analytics, refreshes state") func restorePurchases_success() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()
        provider.subscriptionStatusCalled = false

        // Act
        try await manager.restorePurchases()

        // Assert
        #expect(provider.restorePurchasesCalled == true)
        #expect(analytics.hasTracked(eventNamed: "restore_purchases_started"))
        #expect(analytics.hasTracked(eventNamed: "restore_purchases_completed"))
        #expect(provider.subscriptionStatusCalled == true)
    }

    @Test("Restore failure tracks analytics and rethrows") func restorePurchases_failure_tracksAndRethrows() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let analytics = MockAnalytics()
        provider.restoreError = PurchaseError.networkError("Timeout")
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider, analytics: analytics)
        analytics.reset()

        // Act & Assert
        await #expect(throws: PurchaseError.networkError("Timeout")) {
            try await manager.restorePurchases()
        }
        #expect(analytics.hasTracked(eventNamed: "restore_purchases_failed"))
    }

    @Test("isRestoring is false after restore completes") func restorePurchases_isRestoringResetAfterCompletion() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Act
        try await manager.restorePurchases()

        // Assert
        #expect(manager.isRestoring == false)
    }

    // MARK: - Entitlement Tests

    @Test("hasEntitlement delegates to provider") func hasEntitlement_delegatesToProvider() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.hasEntitlementResult = true
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Act
        let result = await manager.hasEntitlement("premium")

        // Assert
        #expect(provider.hasEntitlementCalled == true)
        #expect(provider.hasEntitlementIdentifier == "premium")
        #expect(result == true)
    }

    @Test("refreshState updates entitlements and subscription status") func refreshState_updatesState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Change provider state after configure
        provider.currentEntitlementsResult = [.mock(id: "premium"), .mock(id: "pro")]
        provider.subscriptionStatusResult = .mock(isSubscribed: true)

        // Act
        await manager.refreshState()

        // Assert
        #expect(manager.currentEntitlements.count == 2)
        #expect(manager.subscriptionStatus?.isSubscribed == true)
    }

    // MARK: - User Management Tests

    @Test("identify delegates to provider with userID") func identify_delegatesToProvider() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)
        provider.identifyCalled = false

        // Act
        try await manager.identify(userID: "user_123")

        // Assert
        #expect(provider.identifyCalled == true)
        #expect(provider.identifyUserID == "user_123")
    }

    @Test("identify with nil userID delegates correctly") func identify_nilUserID_delegatesToProvider() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)
        provider.identifyCalled = false

        // Act
        try await manager.identify(userID: nil)

        // Assert
        #expect(provider.identifyCalled == true)
        #expect(provider.identifyUserID == nil)
    }

    @Test("identify refreshes state") func identify_refreshesState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)
        provider.currentEntitlementsResult = [.mock()]
        provider.currentEntitlementsCalled = false

        // Act
        try await manager.identify(userID: "user_123")

        // Assert
        #expect(provider.currentEntitlementsCalled == true)
    }

    @Test("logOut delegates to provider and refreshes state") func logOut_delegatesToProviderAndRefreshesState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)
        provider.logOutCalled = false
        provider.subscriptionStatusCalled = false

        // Act
        try await manager.logOut()

        // Assert
        #expect(provider.logOutCalled == true)
        #expect(provider.subscriptionStatusCalled == true)
    }

    // MARK: - Convenience Property Tests

    @Test("isSubscribed returns true when subscribed") func isSubscribed_returnsTrue_whenSubscribed() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.subscriptionStatusResult = .mock(isSubscribed: true)
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Assert
        #expect(manager.isSubscribed == true)
    }

    @Test("isSubscribed returns false when not subscribed") func isSubscribed_returnsFalse_whenNotSubscribed() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.subscriptionStatusResult = .mock(isSubscribed: false)
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Assert
        #expect(manager.isSubscribed == false)
    }

    @Test("hasActiveEntitlements returns true with active entitlements") func hasActiveEntitlements_returnsTrue() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.currentEntitlementsResult = [.mock(isActive: true)]
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Assert
        #expect(manager.hasActiveEntitlements == true)
    }

    @Test("hasActiveEntitlements returns false with no active entitlements") func hasActiveEntitlements_returnsFalse() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        provider.currentEntitlementsResult = [.mock(isActive: false)]
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Assert
        #expect(manager.hasActiveEntitlements == false)
    }
}
