//
//  TransactionProviding.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Protocol for handling purchase transactions.
///
/// This protocol abstracts transaction operations like purchasing products,
/// restoring purchases, and syncing with the provider's backend.
public protocol TransactionProviding: Sendable {
    /// Purchase a product.
    ///
    /// - Parameter product: The ``PurchaseProduct`` to purchase.
    /// - Returns: ``PurchaseResult`` indicating the outcome.
    /// - Throws: ``PurchaseError`` if the purchase operation fails.
    func purchase(_ product: PurchaseProduct) async throws -> PurchaseResult

    /// Restore previous purchases.
    ///
    /// This refreshes the user's purchase history from the App Store
    /// and updates their entitlements accordingly.
    ///
    /// - Throws: ``PurchaseError`` if restoration fails.
    func restorePurchases() async throws

    /// Sync purchases with the provider's backend.
    ///
    /// This ensures local state matches the provider's server state.
    ///
    /// - Throws: ``PurchaseError`` if synchronization fails.
    func syncPurchases() async throws
}
