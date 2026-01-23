//
//  Entitlement.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Represents an active entitlement (access right).
///
/// Entitlements abstract the concept of "what the user has access to" from
/// the specific products they purchased. This allows flexibility in how
/// products grant access to features.
///
/// ## Example
///
/// ```swift
/// let entitlements = await purchaseManager.currentEntitlements
/// let hasPremium = entitlements.contains { $0.id == "premium" && $0.isActive }
/// ```
public struct Entitlement: Sendable, Equatable, Identifiable {
    // MARK: - Public Properties

    /// Entitlement identifier.
    public let id: String

    /// Whether the entitlement is currently active.
    public let isActive: Bool

    /// Product identifier that granted this entitlement.
    public let productIdentifier: String?

    /// Expiration date (if applicable).
    public let expiresDate: Date?

    /// Whether this will renew.
    public let willRenew: Bool

    /// Period type (normal, trial, intro, promotional).
    public let periodType: EntitlementPeriodType

    // MARK: - Initialization

    /// Creates an entitlement.
    ///
    /// - Parameters:
    ///   - id: Entitlement identifier.
    ///   - isActive: Whether the entitlement is active.
    ///   - productIdentifier: Product that granted this entitlement.
    ///   - expiresDate: Expiration date.
    ///   - willRenew: Whether it will auto-renew.
    ///   - periodType: The current period type.
    public init(
        id: String,
        isActive: Bool,
        productIdentifier: String? = nil,
        expiresDate: Date? = nil,
        willRenew: Bool = false,
        periodType: EntitlementPeriodType = .normal
    ) {
        self.id = id
        self.isActive = isActive
        self.productIdentifier = productIdentifier
        self.expiresDate = expiresDate
        self.willRenew = willRenew
        self.periodType = periodType
    }
}

// MARK: - Convenience Properties

extension Entitlement {
    /// Whether this entitlement is in a trial period.
    public var isInTrial: Bool {
        periodType == .trial
    }

    /// Whether this entitlement is in an introductory period.
    public var isInIntro: Bool {
        periodType == .intro
    }

    /// Whether this entitlement is about to expire (within 7 days).
    public var isExpiringSoon: Bool {
        guard let expiresDate else { return false }
        let sevenDaysFromNow = Date().addingTimeInterval(7 * 24 * 60 * 60)
        return expiresDate < sevenDaysFromNow
    }
}

// MARK: - EntitlementPeriodType

/// The type of period for an entitlement.
public enum EntitlementPeriodType: String, Sendable, Equatable, CaseIterable {
    /// Standard billing period.
    case normal

    /// Free trial period.
    case trial

    /// Introductory offer period.
    case intro

    /// Promotional period.
    case promotional
}
