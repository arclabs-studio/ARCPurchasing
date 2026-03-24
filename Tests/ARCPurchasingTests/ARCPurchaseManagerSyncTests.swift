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

        // Yield to let the observation Task start and register the stream continuation.
        // The Task is @MainActor so it runs cooperatively — one sleep cycle is enough.
        try await Task.sleep(for: .milliseconds(10))

        // Change provider state then trigger the stream
        provider.currentEntitlementsResult = [.mock(id: "premium"), .mock(id: "pro")]
        provider.subscriptionStatusResult = .mock(isSubscribed: true)
        provider.simulatePurchaseStateChange()

        // Wait for the observation task to call refreshState()
        try await Task.sleep(for: .milliseconds(50))

        // Assert
        #expect(manager.currentEntitlements.count == 2)
        #expect(manager.subscriptionStatus?.isSubscribed == true)
    }
}
