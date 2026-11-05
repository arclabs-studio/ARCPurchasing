//
//  MockPurchaseProvider.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import os
@testable import ARCPurchasing

/// Mock implementation of ``PurchaseProviding`` for testing.
final class MockPurchaseProvider: PurchaseProviding {
    private struct State {
        var isConfigured: Bool = false
        var purchaseStateDidChangeContinuation: AsyncStream<Void>.Continuation?
        var configureError: PurchaseError?
        var fetchProductsResult: Result<[PurchaseProduct], PurchaseError> = .success([])
        var fetchOfferingsResult: Result<[String: [PurchaseProduct]], PurchaseError> = .success([:])
        var purchaseResult: PurchaseResult = .cancelled
        var restoreError: Error?
        var hasEntitlementResult: Bool = false
        var currentEntitlementsResult: [Entitlement] = []
        var subscriptionStatusResult: SubscriptionStatus?
        var onCurrentEntitlementsCalled: (@Sendable () -> Void)?
        var onSubscriptionStatusCalled: (@Sendable () -> Void)?
        var onContinuationRegistered: (@Sendable () -> Void)?
        var configureCalled: Bool = false
        var configureConfig: PurchaseConfiguration?
        var fetchProductsCalled: Bool = false
        var fetchProductsIdentifiers: Set<String>?
        var fetchOfferingsCalled: Bool = false
        var purchaseCalled: Bool = false
        var purchaseProduct: PurchaseProduct?
        var restorePurchasesCalled: Bool = false
        var syncPurchasesCalled: Bool = false
        var hasEntitlementCalled: Bool = false
        var hasEntitlementIdentifier: String?
        var currentEntitlementsCalled: Bool = false
        var subscriptionStatusCalled: Bool = false
        var identifyCalled: Bool = false
        var identifyUserID: String?
        var logOutCalled: Bool = false
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - State

    var isConfigured: Bool {
        get { state.withLock { $0.isConfigured } }
        set { state.withLock { $0.isConfigured = newValue } }
    }

    // MARK: - State Change Stream

    var purchaseStateDidChangeContinuation: AsyncStream<Void>.Continuation? {
        get { state.withLock { $0.purchaseStateDidChangeContinuation } }
        set { state.withLock { $0.purchaseStateDidChangeContinuation = newValue } }
    }

    /// Trigger a simulated purchase state change in tests.
    func simulatePurchaseStateChange() {
        purchaseStateDidChangeContinuation?.yield(())
    }

    // MARK: - Mock Results

    var configureError: PurchaseError? {
        get { state.withLock { $0.configureError } }
        set { state.withLock { $0.configureError = newValue } }
    }

    var fetchProductsResult: Result<[PurchaseProduct], PurchaseError> {
        get { state.withLock { $0.fetchProductsResult } }
        set { state.withLock { $0.fetchProductsResult = newValue } }
    }

    var fetchOfferingsResult: Result<[String: [PurchaseProduct]], PurchaseError> {
        get { state.withLock { $0.fetchOfferingsResult } }
        set { state.withLock { $0.fetchOfferingsResult = newValue } }
    }

    var purchaseResult: PurchaseResult {
        get { state.withLock { $0.purchaseResult } }
        set { state.withLock { $0.purchaseResult = newValue } }
    }

    var restoreError: Error? {
        get { state.withLock { $0.restoreError } }
        set { state.withLock { $0.restoreError = newValue } }
    }

    var hasEntitlementResult: Bool {
        get { state.withLock { $0.hasEntitlementResult } }
        set { state.withLock { $0.hasEntitlementResult = newValue } }
    }

    var currentEntitlementsResult: [Entitlement] {
        get { state.withLock { $0.currentEntitlementsResult } }
        set { state.withLock { $0.currentEntitlementsResult = newValue } }
    }

    var subscriptionStatusResult: SubscriptionStatus? {
        get { state.withLock { $0.subscriptionStatusResult } }
        set { state.withLock { $0.subscriptionStatusResult = newValue } }
    }

    // MARK: - Hooks

    var onCurrentEntitlementsCalled: (@Sendable () -> Void)? {
        get { state.withLock { $0.onCurrentEntitlementsCalled } }
        set { state.withLock { $0.onCurrentEntitlementsCalled = newValue } }
    }

    var onSubscriptionStatusCalled: (@Sendable () -> Void)? {
        get { state.withLock { $0.onSubscriptionStatusCalled } }
        set { state.withLock { $0.onSubscriptionStatusCalled = newValue } }
    }

    var onContinuationRegistered: (@Sendable () -> Void)? {
        get { state.withLock { $0.onContinuationRegistered } }
        set { state.withLock { $0.onContinuationRegistered = newValue } }
    }

    // MARK: - Call Tracking

    var configureCalled: Bool {
        get { state.withLock { $0.configureCalled } }
        set { state.withLock { $0.configureCalled = newValue } }
    }

    var configureConfig: PurchaseConfiguration? {
        get { state.withLock { $0.configureConfig } }
        set { state.withLock { $0.configureConfig = newValue } }
    }

    var fetchProductsCalled: Bool {
        get { state.withLock { $0.fetchProductsCalled } }
        set { state.withLock { $0.fetchProductsCalled = newValue } }
    }

    var fetchProductsIdentifiers: Set<String>? {
        get { state.withLock { $0.fetchProductsIdentifiers } }
        set { state.withLock { $0.fetchProductsIdentifiers = newValue } }
    }

    var fetchOfferingsCalled: Bool {
        get { state.withLock { $0.fetchOfferingsCalled } }
        set { state.withLock { $0.fetchOfferingsCalled = newValue } }
    }

    var purchaseCalled: Bool {
        get { state.withLock { $0.purchaseCalled } }
        set { state.withLock { $0.purchaseCalled = newValue } }
    }

    var purchaseProduct: PurchaseProduct? {
        get { state.withLock { $0.purchaseProduct } }
        set { state.withLock { $0.purchaseProduct = newValue } }
    }

    var restorePurchasesCalled: Bool {
        get { state.withLock { $0.restorePurchasesCalled } }
        set { state.withLock { $0.restorePurchasesCalled = newValue } }
    }

    var syncPurchasesCalled: Bool {
        get { state.withLock { $0.syncPurchasesCalled } }
        set { state.withLock { $0.syncPurchasesCalled = newValue } }
    }

    var hasEntitlementCalled: Bool {
        get { state.withLock { $0.hasEntitlementCalled } }
        set { state.withLock { $0.hasEntitlementCalled = newValue } }
    }

    var hasEntitlementIdentifier: String? {
        get { state.withLock { $0.hasEntitlementIdentifier } }
        set { state.withLock { $0.hasEntitlementIdentifier = newValue } }
    }

    var currentEntitlementsCalled: Bool {
        get { state.withLock { $0.currentEntitlementsCalled } }
        set { state.withLock { $0.currentEntitlementsCalled = newValue } }
    }

    var subscriptionStatusCalled: Bool {
        get { state.withLock { $0.subscriptionStatusCalled } }
        set { state.withLock { $0.subscriptionStatusCalled = newValue } }
    }

    var identifyCalled: Bool {
        get { state.withLock { $0.identifyCalled } }
        set { state.withLock { $0.identifyCalled = newValue } }
    }

    var identifyUserID: String? {
        get { state.withLock { $0.identifyUserID } }
        set { state.withLock { $0.identifyUserID = newValue } }
    }

    var logOutCalled: Bool {
        get { state.withLock { $0.logOutCalled } }
        set { state.withLock { $0.logOutCalled = newValue } }
    }

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
        if let error = restoreError {
            throw error
        }
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
        onCurrentEntitlementsCalled?()
        return currentEntitlementsResult
    }

    func subscriptionStatus() async -> SubscriptionStatus? {
        subscriptionStatusCalled = true
        onSubscriptionStatusCalled?()
        return subscriptionStatusResult
    }

    func purchaseStateDidChange() -> AsyncStream<Void> {
        AsyncStream { continuation in
            self.purchaseStateDidChangeContinuation = continuation
            self.onContinuationRegistered?()
        }
    }
}

// MARK: - Reset

extension MockPurchaseProvider {
    /// Reset all state and call tracking.
    func reset() {
        purchaseStateDidChangeContinuation?.finish()
        purchaseStateDidChangeContinuation = nil
        isConfigured = false
        configureError = nil
        restoreError = nil
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
        onCurrentEntitlementsCalled = nil
        onSubscriptionStatusCalled = nil
        onContinuationRegistered = nil
        currentEntitlementsCalled = false
        subscriptionStatusCalled = false
        identifyCalled = false
        identifyUserID = nil
        logOutCalled = false
    }
}
