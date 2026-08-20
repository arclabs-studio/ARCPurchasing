//
//  ARCPurchaseManagerSyncTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

@MainActor
struct ARCPurchaseManagerSyncTests {
    // MARK: - Sync Purchases Tests

    @Test("syncPurchases throws notConfigured before configure") func syncPurchases_beforeConfigure_throwsNotConfigured() async {
        let manager = ARCPurchaseManager()
        await #expect(throws: PurchaseError.notConfigured) {
            try await manager.syncPurchases()
        }
    }

    @Test("syncPurchases delegates to provider and refreshes state") func syncPurchases_delegatesToProviderAndRefreshesState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)
        provider.syncPurchasesCalled = false
        provider.subscriptionStatusCalled = false

        // Act
        try await manager.syncPurchases()

        // Assert
        #expect(provider.syncPurchasesCalled == true)
        #expect(provider.subscriptionStatusCalled == true)
    }

    // MARK: - Real-time State Updates Tests

    @Test("State updates when purchaseStateDidChange stream emits",
          .timeLimit(.minutes(1))) func purchaseStateDidChange_updatesManagerState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Set provider state to reflect what a renewal would deliver.
        provider.currentEntitlementsResult = [.mock(id: "premium"), .mock(id: "pro")]
        provider.subscriptionStatusResult = .mock(isSubscribed: true)

        // The manager's observation Task lazily registers the AsyncStream continuation
        // when it begins iterating. Yield until the mock confirms registration so the
        // emission below cannot be dropped because of scheduling order.
        for _ in 0 ..< 500 where provider.purchaseStateDidChangeContinuation == nil {
            await Task.yield()
        }
        try #require(provider.purchaseStateDidChangeContinuation != nil)

        // Trigger the state change the manager should react to.
        provider.simulatePurchaseStateChange()

        // refreshState() reads currentEntitlements then subscriptionStatus and
        // finally assigns both properties on @MainActor. Poll until the assignment
        // completes; the .timeLimit trait bounds the wait if it never does.
        for _ in 0 ..< 500 where manager.subscriptionStatus?.isSubscribed != true {
            await Task.yield()
        }

        // Assert
        #expect(manager.currentEntitlements.count == 2)
        #expect(manager.subscriptionStatus?.isSubscribed == true)
    }
}
