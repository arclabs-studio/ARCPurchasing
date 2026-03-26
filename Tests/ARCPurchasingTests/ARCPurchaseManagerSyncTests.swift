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

    @Test("State updates when purchaseStateDidChange stream emits") func purchaseStateDidChange_updatesManagerState() async throws {
        // Arrange
        let provider = MockPurchaseProvider()
        let manager = ARCPurchaseManager()
        try await manager.configure(with: .mock(), provider: provider)

        // Set provider state to reflect what a renewal would deliver
        provider.currentEntitlementsResult = [.mock(id: "premium"), .mock(id: "pro")]
        provider.subscriptionStatusResult = .mock(isSubscribed: true)

        // Schedule emission in a separate Task. On @MainActor, tasks run in enqueue order,
        // so the observation Task (created by configure) registers its stream continuation
        // before this emission fires.
        Task { @MainActor [provider] in
            provider.simulatePurchaseStateChange()
        }

        // Wait for subscriptionStatus() to be called inside refreshState().
        // NOTE: onSubscriptionStatusCalled fires from WITHIN subscriptionStatus() before
        // it returns, so our continuation is enqueued on @MainActor before refreshState()
        // can assign `self.subscriptionStatus = result`. One Task.yield() lets that
        // assignment run to completion before we assert.
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            provider.onSubscriptionStatusCalled = { continuation.resume() }
        }
        await Task.yield()

        // Assert
        #expect(manager.currentEntitlements.count == 2)
        #expect(manager.subscriptionStatus?.isSubscribed == true)
    }
}
