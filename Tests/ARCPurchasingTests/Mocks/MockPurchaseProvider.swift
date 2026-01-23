//
//  MockPurchaseProvider.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
@testable import ARCPurchasing

/// Mock implementation of ``PurchaseProviding`` for testing.
final class MockPurchaseProvider: PurchaseProviding, @unchecked Sendable {
    // MARK: - State

    var isConfigured = false

    // MARK: - Mock Results

    var configureError: PurchaseError?
    var fetchProductsResult: Result<[PurchaseProduct], PurchaseError> = .success([])
    var fetchOfferingsResult: Result<[String: [PurchaseProduct]], PurchaseError> = .success([:])
    var purchaseResult: PurchaseResult = .cancelled
    var hasEntitlementResult = false
    var currentEntitlementsResult: [Entitlement] = []
    var subscriptionStatusResult: SubscriptionStatus?

    // MARK: - Call Tracking

    var configureCalled = false
    var configureConfig: PurchaseConfiguration?
    var fetchProductsCalled = false
    var fetchProductsIdentifiers: Set<String>?
    var fetchOfferingsCalled = false
    var purchaseCalled = false
    var purchaseProduct: PurchaseProduct?
    var restorePurchasesCalled = false
    var syncPurchasesCalled = false
    var hasEntitlementCalled = false
    var hasEntitlementIdentifier: String?
    var currentEntitlementsCalled = false
    var subscriptionStatusCalled = false
    var identifyCalled = false
    var identifyUserID: String?
    var logOutCalled = false

    // MARK: - PurchaseProviding

    func configure(with config: PurchaseConfiguration) async throws {
        configureCalled = true
        configureConfig = config

        if let error = configureError {
            throw error
        }

        isConfigured = true
    }

    func identify(userID: String?) async throws {
        identifyCalled = true
        identifyUserID = userID
    }

    func logOut() async throws {
        logOutCalled = true
    }

    // MARK: - ProductProviding

    func fetchProducts(for identifiers: Set<String>) async throws -> [PurchaseProduct] {
        fetchProductsCalled = true
        fetchProductsIdentifiers = identifiers
        return try fetchProductsResult.get()
    }

    func fetchOfferings() async throws -> [String: [PurchaseProduct]] {
        fetchOfferingsCalled = true
        return try fetchOfferingsResult.get()
    }

    // MARK: - TransactionProviding

    func purchase(_ product: PurchaseProduct) async throws -> PurchaseResult {
        purchaseCalled = true
        purchaseProduct = product
        return purchaseResult
    }

    func restorePurchases() async throws {
        restorePurchasesCalled = true
    }

    func syncPurchases() async throws {
        syncPurchasesCalled = true
    }

    // MARK: - EntitlementProviding

    func hasEntitlement(_ identifier: String) async -> Bool {
        hasEntitlementCalled = true
        hasEntitlementIdentifier = identifier
        return hasEntitlementResult
    }

    func currentEntitlements() async -> [Entitlement] {
        currentEntitlementsCalled = true
        return currentEntitlementsResult
    }

    func subscriptionStatus() async -> SubscriptionStatus? {
        subscriptionStatusCalled = true
        return subscriptionStatusResult
    }
}

// MARK: - Reset

extension MockPurchaseProvider {
    /// Reset all state and call tracking.
    func reset() {
        isConfigured = false
        configureError = nil
        fetchProductsResult = .success([])
        fetchOfferingsResult = .success([:])
        purchaseResult = .cancelled
        hasEntitlementResult = false
        currentEntitlementsResult = []
        subscriptionStatusResult = nil

        configureCalled = false
        configureConfig = nil
        fetchProductsCalled = false
        fetchProductsIdentifiers = nil
        fetchOfferingsCalled = false
        purchaseCalled = false
        purchaseProduct = nil
        restorePurchasesCalled = false
        syncPurchasesCalled = false
        hasEntitlementCalled = false
        hasEntitlementIdentifier = nil
        currentEntitlementsCalled = false
        subscriptionStatusCalled = false
        identifyCalled = false
        identifyUserID = nil
        logOutCalled = false
    }
}
