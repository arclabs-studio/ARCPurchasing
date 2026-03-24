//
//  ARCPurchaseManagerSyncTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

@Suite("ARCPurchaseManager Sync & Stream Tests")
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

        // Wait deterministically for refreshState() to complete.
        // subscriptionStatus() is the last call in refreshState(), so by the time
        // resume() is called both state assignments have already been made.
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            provider.onSubscriptionStatusCalled = { continuation.resume() }
        }

        // Assert
        #expect(manager.currentEntitlements.count == 2)
        #expect(manager.subscriptionStatus?.isSubscribed == true)
    }
}
