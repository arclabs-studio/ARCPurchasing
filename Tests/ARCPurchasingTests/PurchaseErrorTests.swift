//
//  PurchaseErrorTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Testing
@testable import ARCPurchasing

@Suite("PurchaseError Tests")
struct PurchaseErrorTests {
    // MARK: - Error Description Tests

    @Test("notConfigured has correct description")
    func notConfigured_hasCorrectDescription() {
        let error = PurchaseError.notConfigured
        #expect(error.errorDescription?.contains("not configured") == true)
    }

    @Test("invalidAPIKey has correct description")
    func invalidAPIKey_hasCorrectDescription() {
        let error = PurchaseError.invalidAPIKey
        #expect(error.errorDescription?.contains("Invalid API key") == true)
    }

    @Test("productNotFound includes product ID")
    func productNotFound_includesProductID() {
        let error = PurchaseError.productNotFound("com.test.product")
        #expect(error.errorDescription?.contains("com.test.product") == true)
    }

    @Test("networkError includes reason")
    func networkError_includesReason() {
        let error = PurchaseError.networkError("Connection timeout")
        #expect(error.errorDescription?.contains("Connection timeout") == true)
    }

    // MARK: - Retryable Tests

    @Test("Network errors are retryable")
    func networkErrors_areRetryable() {
        #expect(PurchaseError.networkError("test").isRetryable == true)
        #expect(PurchaseError.timeout.isRetryable == true)
    }

    @Test("Configuration errors are not retryable")
    func configurationErrors_areNotRetryable() {
        #expect(PurchaseError.notConfigured.isRetryable == false)
        #expect(PurchaseError.invalidAPIKey.isRetryable == false)
    }

    @Test("User cancellation is not retryable")
    func userCancellation_isNotRetryable() {
        #expect(PurchaseError.userCancelled.isRetryable == false)
    }

    // MARK: - Recovery Suggestion Tests

    @Test("Network error has recovery suggestion")
    func networkError_hasRecoverySuggestion() {
        let error = PurchaseError.networkError("test")
        #expect(error.recoverySuggestion != nil)
        #expect(error.recoverySuggestion?.contains("internet connection") == true)
    }

    @Test("purchaseNotAllowed has recovery suggestion")
    func purchaseNotAllowed_hasRecoverySuggestion() {
        let error = PurchaseError.purchaseNotAllowed
        #expect(error.recoverySuggestion != nil)
        #expect(error.recoverySuggestion?.contains("device settings") == true)
    }

    // MARK: - Equatable Tests

    @Test("PurchaseError equality works correctly")
    func purchaseError_equalityWorks() {
        #expect(PurchaseError.notConfigured == PurchaseError.notConfigured)
        #expect(PurchaseError.timeout == PurchaseError.timeout)
        #expect(PurchaseError.productNotFound("a") == PurchaseError.productNotFound("a"))
        #expect(PurchaseError.productNotFound("a") != PurchaseError.productNotFound("b"))
    }
}
