//
//  PurchaseAnalytics.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Protocol for tracking purchase analytics.
///
/// Implement this protocol to integrate with your preferred analytics service.
/// The default implementation uses ``ARCLogger`` for logging events.
///
/// ## Example Custom Implementation
///
/// ```swift
/// final class FirebaseAnalytics: PurchaseAnalytics {
///     func track(_ event: PurchaseEvent) async {
///         switch event {
///         case .purchaseCompleted(let productID, let price, let currency, let transactionID):
///             Analytics.logEvent(AnalyticsEventPurchase, parameters: [
///                 AnalyticsParameterItemID: productID,
///                 AnalyticsParameterPrice: price,
///                 AnalyticsParameterCurrency: currency,
///                 AnalyticsParameterTransactionID: transactionID
///             ])
///         default:
///             Analytics.logEvent(event.name, parameters: nil)
///         }
///     }
/// }
/// ```
public protocol PurchaseAnalytics: Sendable {
    /// Track a purchase event.
    ///
    /// - Parameter event: The ``PurchaseEvent`` to track.
    func track(_ event: PurchaseEvent) async
}
