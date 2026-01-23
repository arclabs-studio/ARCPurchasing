//
//  DefaultPurchaseAnalytics.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCLogger
import Foundation

/// Default analytics implementation using ARCLogger.
///
/// This implementation logs all purchase events using the ARCLogger framework,
/// providing a simple way to track purchase activity during development and debugging.
public final class DefaultPurchaseAnalytics: PurchaseAnalytics {
    // MARK: - Private Properties

    private let logger: ARCLogger

    // MARK: - Initialization

    /// Creates a default purchase analytics instance.
    ///
    /// - Parameter logger: Logger instance for tracking events.
    public init(logger: ARCLogger = .shared) {
        self.logger = logger
    }

    // MARK: - PurchaseAnalytics

    // swiftlint:disable:next cyclomatic_complexity
    public func track(_ event: PurchaseEvent) async {
        switch event {
        case let .productViewed(productID):
            logger.info("[Analytics] Product viewed: \(productID)")

        case let .paywallViewed(paywallID):
            logger.info("[Analytics] Paywall viewed: \(paywallID ?? "default")")

        case let .purchaseStarted(productID):
            logger.info("[Analytics] Purchase started: \(productID)")

        case let .purchaseCompleted(productID, price, currency, transactionID):
            let message = "[Analytics] Purchase completed: \(productID), "
                + "price: \(price) \(currency), transaction: \(transactionID)"
            logger.info(message)

        case let .purchaseCancelled(productID):
            logger.info("[Analytics] Purchase cancelled: \(productID)")

        case let .purchaseFailed(productID, error):
            logger.warning("[Analytics] Purchase failed: \(productID), error: \(error)")

        case let .purchasePending(productID):
            logger.info("[Analytics] Purchase pending: \(productID)")

        case let .subscriptionRenewed(productID):
            logger.info("[Analytics] Subscription renewed: \(productID)")

        case let .subscriptionCancelled(productID):
            logger.info("[Analytics] Subscription cancelled: \(productID)")

        case let .subscriptionExpired(productID):
            logger.info("[Analytics] Subscription expired: \(productID)")

        case .restorePurchasesStarted:
            logger.info("[Analytics] Restore purchases started")

        case .restorePurchasesCompleted:
            logger.info("[Analytics] Restore purchases completed")

        case let .restorePurchasesFailed(error):
            logger.warning("[Analytics] Restore purchases failed: \(error)")
        }
    }
}
