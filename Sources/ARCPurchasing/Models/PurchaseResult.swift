//
//  PurchaseResult.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Result of a purchase attempt.
///
/// `PurchaseResult` encapsulates all possible outcomes of a purchase operation,
/// from success to cancellation and pending states.
///
/// ## Example
///
/// ```swift
/// let result = try await purchaseManager.purchase(product)
/// switch result {
/// case .success(let transaction):
///     print("Purchased: \(transaction.productID)")
/// case .cancelled:
///     print("User cancelled")
/// case .pending:
///     print("Awaiting approval")
/// case .requiresAction(let action):
///     print("Action required: \(action)")
/// case .unknown:
///     print("Unknown result")
/// }
/// ```
public enum PurchaseResult: Sendable, Equatable {
    /// Purchase completed successfully.
    case success(PurchaseTransaction)

    /// User cancelled the purchase.
    case cancelled

    /// Purchase is pending (e.g., awaiting parental approval).
    case pending

    /// Purchase requires user action (e.g., payment method update).
    case requiresAction(String)

    /// Unknown result.
    case unknown
}

// MARK: - Convenience Properties

extension PurchaseResult {
    /// Whether the purchase was successful.
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    /// The transaction if purchase was successful, `nil` otherwise.
    public var transaction: PurchaseTransaction? {
        if case let .success(transaction) = self { return transaction }
        return nil
    }

    /// Whether the user cancelled the purchase.
    public var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }

    /// Whether the purchase is pending approval.
    public var isPending: Bool {
        if case .pending = self { return true }
        return false
    }
}
