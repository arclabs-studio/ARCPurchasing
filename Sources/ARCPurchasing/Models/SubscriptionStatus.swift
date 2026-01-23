//
//  SubscriptionStatus.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Current subscription status for the user.
///
/// `SubscriptionStatus` provides a comprehensive view of the user's
/// subscription state, including billing status and management options.
public struct SubscriptionStatus: Sendable, Equatable {
    // MARK: - Public Properties

    /// Whether user has any active subscription.
    public let isSubscribed: Bool

    /// Active subscription product ID.
    public let activeProductID: String?

    /// Expiration date of current subscription.
    public let expiresDate: Date?

    /// Whether subscription will auto-renew.
    public let willRenew: Bool

    /// Whether user is in billing retry period.
    public let isInBillingRetry: Bool

    /// Whether user is in grace period.
    public let isInGracePeriod: Bool

    /// Subscription management URL (App Store subscription settings).
    public let managementURL: URL?

    // MARK: - Initialization

    /// Creates a subscription status.
    ///
    /// - Parameters:
    ///   - isSubscribed: Whether user has an active subscription.
    ///   - activeProductID: The active subscription product ID.
    ///   - expiresDate: Subscription expiration date.
    ///   - willRenew: Whether it will auto-renew.
    ///   - isInBillingRetry: Whether in billing retry period.
    ///   - isInGracePeriod: Whether in grace period.
    ///   - managementURL: URL to manage subscription.
    public init(
        isSubscribed: Bool,
        activeProductID: String? = nil,
        expiresDate: Date? = nil,
        willRenew: Bool = false,
        isInBillingRetry: Bool = false,
        isInGracePeriod: Bool = false,
        managementURL: URL? = nil
    ) {
        self.isSubscribed = isSubscribed
        self.activeProductID = activeProductID
        self.expiresDate = expiresDate
        self.willRenew = willRenew
        self.isInBillingRetry = isInBillingRetry
        self.isInGracePeriod = isInGracePeriod
        self.managementURL = managementURL
    }
}

// MARK: - Convenience Properties

extension SubscriptionStatus {
    /// Whether the subscription is active and in good standing.
    public var isActiveAndHealthy: Bool {
        isSubscribed && !isInBillingRetry && !isInGracePeriod
    }

    /// Whether the subscription has any billing issues.
    public var hasBillingIssues: Bool {
        isInBillingRetry || isInGracePeriod
    }

    /// Whether the subscription is about to expire (within 3 days).
    public var isExpiringSoon: Bool {
        guard let expiresDate, !willRenew else { return false }
        let threeDaysFromNow = Date().addingTimeInterval(3 * 24 * 60 * 60)
        return expiresDate < threeDaysFromNow
    }

    /// Number of days until expiration, or `nil` if no expiration date.
    public var daysUntilExpiration: Int? {
        guard let expiresDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiresDate)
        return components.day
    }
}
