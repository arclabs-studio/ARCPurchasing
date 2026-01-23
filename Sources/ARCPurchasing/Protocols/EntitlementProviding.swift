//
//  EntitlementProviding.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Protocol for checking user entitlements.
///
/// Entitlements represent what features or content a user has access to,
/// independent of the specific products they purchased.
public protocol EntitlementProviding: Sendable {
    /// Check if user has access to a specific entitlement.
    ///
    /// - Parameter identifier: The entitlement identifier to check.
    /// - Returns: `true` if user has an active entitlement, `false` otherwise.
    func hasEntitlement(_ identifier: String) async -> Bool

    /// Get all current entitlements for the user.
    ///
    /// - Returns: Array of active ``Entitlement`` objects.
    func currentEntitlements() async -> [Entitlement]

    /// Get the current subscription status.
    ///
    /// - Returns: ``SubscriptionStatus`` if user has any subscription, `nil` otherwise.
    func subscriptionStatus() async -> SubscriptionStatus?
}
