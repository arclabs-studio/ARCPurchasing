//
//  PurchaseTransaction.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Represents a completed purchase transaction.
///
/// `PurchaseTransaction` contains all relevant information about a completed
/// purchase, including transaction identifiers, dates, and pricing details.
public struct PurchaseTransaction: Sendable, Equatable, Identifiable {
    // MARK: - Public Properties

    /// Unique transaction identifier.
    public let id: String

    /// Product identifier.
    public let productID: String

    /// Original transaction ID (for subscription renewals).
    public let originalTransactionID: String?

    /// Purchase date.
    public let purchaseDate: Date

    /// Expiration date (for subscriptions).
    public let expiresDate: Date?

    /// Whether this is a restored purchase.
    public let isRestored: Bool

    /// Price at time of purchase.
    public let price: Decimal?

    /// Currency code at time of purchase.
    public let currencyCode: String?

    // MARK: - Initialization

    /// Creates a purchase transaction.
    ///
    /// - Parameters:
    ///   - id: Unique transaction identifier.
    ///   - productID: Product identifier.
    ///   - originalTransactionID: Original transaction ID for renewals.
    ///   - purchaseDate: Date of purchase.
    ///   - expiresDate: Expiration date for subscriptions.
    ///   - isRestored: Whether this is a restored purchase.
    ///   - price: Price at time of purchase.
    ///   - currencyCode: Currency code.
    public init(
        id: String,
        productID: String,
        originalTransactionID: String? = nil,
        purchaseDate: Date,
        expiresDate: Date? = nil,
        isRestored: Bool = false,
        price: Decimal? = nil,
        currencyCode: String? = nil
    ) {
        self.id = id
        self.productID = productID
        self.originalTransactionID = originalTransactionID
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
        self.isRestored = isRestored
        self.price = price
        self.currencyCode = currencyCode
    }
}
