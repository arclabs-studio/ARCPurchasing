//
//  PurchaseEvent.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Events tracked by the purchase system.
///
/// `PurchaseEvent` captures all significant actions in the purchase flow,
/// enabling analytics tracking and debugging.
public enum PurchaseEvent: Sendable {
    // MARK: - Product Events

    /// A product was viewed by the user.
    case productViewed(productID: String)

    /// A paywall was displayed.
    case paywallViewed(paywallID: String?)

    // MARK: - Purchase Events

    /// A purchase was initiated.
    case purchaseStarted(productID: String)

    /// A purchase completed successfully.
    case purchaseCompleted(
        productID: String,
        price: Decimal,
        currency: String,
        transactionID: String
    )

    /// A purchase was cancelled by the user.
    case purchaseCancelled(productID: String)

    /// A purchase failed with an error.
    case purchaseFailed(productID: String, error: String)

    /// A purchase is pending approval.
    case purchasePending(productID: String)

    // MARK: - Subscription Events

    /// A subscription was renewed.
    case subscriptionRenewed(productID: String)

    /// A subscription was cancelled.
    case subscriptionCancelled(productID: String)

    /// A subscription expired.
    case subscriptionExpired(productID: String)

    // MARK: - Restore Events

    /// Restore purchases operation started.
    case restorePurchasesStarted

    /// Restore purchases completed successfully.
    case restorePurchasesCompleted

    /// Restore purchases failed.
    case restorePurchasesFailed(error: String)
}

// MARK: - Event Metadata

extension PurchaseEvent {
    /// Event name for analytics tracking.
    public var name: String {
        switch self {
        case .productViewed: "product_viewed"
        case .paywallViewed: "paywall_viewed"
        case .purchaseStarted: "purchase_started"
        case .purchaseCompleted: "purchase_completed"
        case .purchaseCancelled: "purchase_cancelled"
        case .purchaseFailed: "purchase_failed"
        case .purchasePending: "purchase_pending"
        case .subscriptionRenewed: "subscription_renewed"
        case .subscriptionCancelled: "subscription_cancelled"
        case .subscriptionExpired: "subscription_expired"
        case .restorePurchasesStarted: "restore_purchases_started"
        case .restorePurchasesCompleted: "restore_purchases_completed"
        case .restorePurchasesFailed: "restore_purchases_failed"
        }
    }

    /// Product ID associated with the event, if any.
    public var productID: String? {
        switch self {
        case let .productViewed(productID),
             let .purchaseStarted(productID),
             let .purchaseCompleted(productID, _, _, _),
             let .purchaseCancelled(productID),
             let .purchaseFailed(productID, _),
             let .purchasePending(productID),
             let .subscriptionRenewed(productID),
             let .subscriptionCancelled(productID),
             let .subscriptionExpired(productID):
            productID
        case .paywallViewed, .restorePurchasesStarted, .restorePurchasesCompleted, .restorePurchasesFailed:
            nil
        }
    }
}
