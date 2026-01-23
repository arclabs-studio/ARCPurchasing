//
//  PurchaseResultTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Testing
@testable import ARCPurchasing

@Suite("PurchaseResult Tests")
struct PurchaseResultTests {
    // MARK: - Success Tests

    @Test("isSuccess returns true for success case")
    func isSuccess_returnsTrueForSuccessCase() {
        let transaction = PurchaseTransaction.mock()
        let result = PurchaseResult.success(transaction)
        #expect(result.isSuccess == true)
    }

    @Test("isSuccess returns false for non-success cases")
    func isSuccess_returnsFalseForNonSuccessCases() {
        #expect(PurchaseResult.cancelled.isSuccess == false)
        #expect(PurchaseResult.pending.isSuccess == false)
        #expect(PurchaseResult.requiresAction("test").isSuccess == false)
        #expect(PurchaseResult.unknown.isSuccess == false)
    }

    // MARK: - Transaction Tests

    @Test("transaction returns transaction for success case")
    func transaction_returnsTransactionForSuccessCase() {
        let transaction = PurchaseTransaction.mock(id: "test_txn")
        let result = PurchaseResult.success(transaction)
        #expect(result.transaction?.id == "test_txn")
    }

    @Test("transaction returns nil for non-success cases")
    func transaction_returnsNilForNonSuccessCases() {
        #expect(PurchaseResult.cancelled.transaction == nil)
        #expect(PurchaseResult.pending.transaction == nil)
        #expect(PurchaseResult.requiresAction("test").transaction == nil)
        #expect(PurchaseResult.unknown.transaction == nil)
    }

    // MARK: - Cancelled Tests

    @Test("isCancelled returns true for cancelled case")
    func isCancelled_returnsTrueForCancelledCase() {
        #expect(PurchaseResult.cancelled.isCancelled == true)
    }

    @Test("isCancelled returns false for non-cancelled cases")
    func isCancelled_returnsFalseForNonCancelledCases() {
        let transaction = PurchaseTransaction.mock()
        #expect(PurchaseResult.success(transaction).isCancelled == false)
        #expect(PurchaseResult.pending.isCancelled == false)
    }

    // MARK: - Pending Tests

    @Test("isPending returns true for pending case")
    func isPending_returnsTrueForPendingCase() {
        #expect(PurchaseResult.pending.isPending == true)
    }

    @Test("isPending returns false for non-pending cases")
    func isPending_returnsFalseForNonPendingCases() {
        #expect(PurchaseResult.cancelled.isPending == false)
        #expect(PurchaseResult.unknown.isPending == false)
    }

    // MARK: - Equatable Tests

    @Test("PurchaseResult equality works correctly")
    func purchaseResult_equalityWorks() {
        #expect(PurchaseResult.cancelled == PurchaseResult.cancelled)
        #expect(PurchaseResult.pending == PurchaseResult.pending)
        #expect(PurchaseResult.unknown == PurchaseResult.unknown)
        #expect(PurchaseResult.requiresAction("test") == PurchaseResult.requiresAction("test"))
        #expect(PurchaseResult.requiresAction("test") != PurchaseResult.requiresAction("other"))
    }
}
