//
//  SubscriptionStatusResolver.swift
//  ARCPurchasingRevenueCat
//
//  Created by ARC Labs Studio on 10/08/2026.
//

import ARCPurchasing
import Foundation

// MARK: - ActiveEntitlementSnapshot

/// Value snapshot of an active entitlement used for status resolution.
///
/// Decouples the resolution logic from RevenueCat's `EntitlementInfo`
/// (which has no public initializer) so the logic is unit-testable.
struct ActiveEntitlementSnapshot: Equatable {
    /// Entitlement identifier as configured in the backend dashboard.
    let identifier: String

    /// Product identifier backing the entitlement.
    let productIdentifier: String

    /// Expiration date; `nil` means non-expiring (lifetime purchase).
    let expirationDate: Date?

    /// Whether the underlying subscription will auto-renew.
    /// `false` for promotional grants and lifetime purchases.
    let willRenew: Bool

    /// When a billing issue was detected, if any.
    let billingIssueDetectedAt: Date?
}

// MARK: - SubscriptionStatusResolver

/// Pure resolution of ``SubscriptionStatus`` from customer-info facts.
///
/// Resolution rules:
/// - When `configuredIdentifiers` is non-empty, any active entitlement
///   whose identifier is in the set counts as subscribed. This covers
///   store subscriptions, lifetime (non-consumable) purchases, and
///   promotional entitlements granted from the backend dashboard.
/// - Store subscriptions (`activeSubscriptions`) always count as
///   subscribed, independent of entitlement configuration.
/// - When `configuredIdentifiers` is empty, behavior is the legacy
///   `!activeSubscriptions.isEmpty` — entitlements alone never subscribe.
enum SubscriptionStatusResolver {
    static func resolve(activeSubscriptions: Set<String>,
                        activeEntitlements: [ActiveEntitlementSnapshot],
                        configuredIdentifiers: Set<String>,
                        managementURL: URL?) -> SubscriptionStatus {
        let relevant = activeEntitlements.filter { configuredIdentifiers.contains($0.identifier) }
        let isSubscribed = !activeSubscriptions.isEmpty || !relevant.isEmpty

        let primary = primaryEntitlement(relevant: relevant, all: activeEntitlements)

        let isInBillingRetry = primary?.billingIssueDetectedAt != nil

        return SubscriptionStatus(isSubscribed: isSubscribed,
                                  activeProductID: primary?.productIdentifier,
                                  expiresDate: primary?.expirationDate,
                                  willRenew: primary?.willRenew ?? false,
                                  isInBillingRetry: isInBillingRetry,
                                  isInGracePeriod: isInBillingRetry,
                                  managementURL: managementURL)
    }
}

// MARK: - Private Helpers

private extension SubscriptionStatusResolver {
    /// Picks the entitlement that best represents the user's access:
    /// configured entitlements win over unconfigured ones, then the
    /// latest expiration wins (`nil` expiration means lifetime and sorts
    /// last-to-expire), then identifier for determinism.
    static func primaryEntitlement(relevant: [ActiveEntitlementSnapshot],
                                   all: [ActiveEntitlementSnapshot]) -> ActiveEntitlementSnapshot? {
        let candidates = relevant.isEmpty ? all : relevant
        return candidates.max { lhs, rhs in
            let lhsExpiry = lhs.expirationDate ?? .distantFuture
            let rhsExpiry = rhs.expirationDate ?? .distantFuture
            if lhsExpiry != rhsExpiry {
                return lhsExpiry < rhsExpiry
            }
            return lhs.identifier > rhs.identifier
        }
    }
}
