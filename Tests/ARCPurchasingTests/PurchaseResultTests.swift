//
//  PurchaseResultTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Testing
@testable import ARCPurchasing

struct PurchaseResultTests {
    // MARK: - Success Tests

    @Test("isSuccess returns true for success case") func isSuccess_returnsTrueForSuccessCase() {
        let transaction = PurchaseTransaction.mock()
        let result = PurchaseResult.success(transaction)
        #expect(result.isSuccess == true)
    }

    @Test("isSuccess returns false for non-success cases") func isSuccess_returnsFalseForNonSuccessCases() {
        #expect(PurchaseResult.cancelled.isSuccess == false)
        #expect(PurchaseResult.pending.isSuccess == false)
        #expect(PurchaseResult.requiresAction("test").isSuccess == false)
        #expect(PurchaseResult.restored.isSuccess == false)
        #expect(PurchaseResult.unknown.isSuccess == false)
    }

    // MARK: - Transaction Tests

    @Test("transaction returns transaction for success case") func transaction_returnsTransactionForSuccessCase() {
        let transaction = PurchaseTransaction.mock(id: "test_txn")
        let result = PurchaseResult.success(transaction)
        #expect(result.transaction?.id == "test_txn")
    }

    @Test("transaction returns nil for non-success cases") func transaction_returnsNilForNonSuccessCases() {
        #expect(PurchaseResult.cancelled.transaction == nil)
        #expect(PurchaseResult.pending.transaction == nil)
        #expect(PurchaseResult.requiresAction("test").transaction == nil)
        #expect(PurchaseResult.restored.transaction == nil)
        #expect(PurchaseResult.unknown.transaction == nil)
    }

    // MARK: - Cancelled Tests

    @Test("isCancelled returns true for cancelled case") func isCancelled_returnsTrueForCancelledCase() {
        #expect(PurchaseResult.cancelled.isCancelled == true)
    }

    @Test("isCancelled returns false for non-cancelled cases") func isCancelled_returnsFalseForNonCancelledCases() {
        let transaction = PurchaseTransaction.mock()
        #expect(PurchaseResult.success(transaction).isCancelled == false)
        #expect(PurchaseResult.pending.isCancelled == false)
    }

    // MARK: - Pending Tests

    @Test("isPending returns true for pending case") func isPending_returnsTrueForPendingCase() {
        #expect(PurchaseResult.pending.isPending == true)
    }

    @Test("isPending returns false for non-pending cases") func isPending_returnsFalseForNonPendingCases() {
        #expect(PurchaseResult.cancelled.isPending == false)
        #expect(PurchaseResult.unknown.isPending == false)
    }

    // MARK: - Restored Tests

    @Test("isRestored returns true for restored case") func isRestored_returnsTrueForRestoredCase() {
        #expect(PurchaseResult.restored.isRestored == true)
    }

    @Test("isRestored returns false for non-restored cases") func isRestored_returnsFalseForNonRestoredCases() {
        let transaction = PurchaseTransaction.mock()
        #expect(PurchaseResult.success(transaction).isRestored == false)
        #expect(PurchaseResult.cancelled.isRestored == false)
        #expect(PurchaseResult.pending.isRestored == false)
        #expect(PurchaseResult.requiresAction("test").isRestored == false)
        #expect(PurchaseResult.unknown.isRestored == false)
    }

    // MARK: - Completed Tests

    @Test("isCompleted returns true for success and restored") func isCompleted_returnsTrueForCompletedOutcomes() {
        #expect(PurchaseResult.success(PurchaseTransaction.mock()).isCompleted == true)
        #expect(PurchaseResult.restored.isCompleted == true)
    }

    @Test("isCompleted returns false for non-completed cases") func isCompleted_returnsFalseForNonCompletedCases() {
        #expect(PurchaseResult.cancelled.isCompleted == false)
        #expect(PurchaseResult.pending.isCompleted == false)
        #expect(PurchaseResult.requiresAction("test").isCompleted == false)
        #expect(PurchaseResult.unknown.isCompleted == false)
    }

    // MARK: - Equatable Tests

    @Test("PurchaseResult equality works correctly") func purchaseResult_equalityWorks() {
        #expect(PurchaseResult.cancelled == PurchaseResult.cancelled)
        #expect(PurchaseResult.pending == PurchaseResult.pending)
        #expect(PurchaseResult.unknown == PurchaseResult.unknown)
        #expect(PurchaseResult.restored == PurchaseResult.restored)
        #expect(PurchaseResult.requiresAction("test") == PurchaseResult.requiresAction("test"))
        #expect(PurchaseResult.requiresAction("test") != PurchaseResult.requiresAction("other"))
        #expect(PurchaseResult.restored != PurchaseResult.unknown)
    }
}
