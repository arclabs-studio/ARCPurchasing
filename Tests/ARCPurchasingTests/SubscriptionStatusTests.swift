//
//  SubscriptionStatusTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

@Suite("SubscriptionStatus Tests")
struct SubscriptionStatusTests {
    // MARK: - Initialization Tests

    @Test("Initialization sets all properties correctly")
    func initialization_setsAllProperties() {
        let expiresDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
        let managementURL = URL(string: "https://apps.apple.com/account/subscriptions")

        let status = SubscriptionStatus(
            isSubscribed: true,
            activeProductID: "com.app.premium.monthly",
            expiresDate: expiresDate,
            willRenew: true,
            isInBillingRetry: false,
            isInGracePeriod: false,
            managementURL: managementURL
        )

        #expect(status.isSubscribed == true)
        #expect(status.activeProductID == "com.app.premium.monthly")
        #expect(status.expiresDate == expiresDate)
        #expect(status.willRenew == true)
        #expect(status.isInBillingRetry == false)
        #expect(status.isInGracePeriod == false)
        #expect(status.managementURL == managementURL)
    }

    // MARK: - Convenience Property Tests

    @Test("isActiveAndHealthy returns true when subscribed without issues")
    func isActiveAndHealthy_returnsTrueWhenSubscribedWithoutIssues() {
        let status = SubscriptionStatus.mock(isSubscribed: true)
        #expect(status.isActiveAndHealthy == true)
    }

    @Test("isActiveAndHealthy returns false when in billing retry")
    func isActiveAndHealthy_returnsFalseWhenInBillingRetry() {
        let status = SubscriptionStatus(
            isSubscribed: true,
            isInBillingRetry: true
        )
        #expect(status.isActiveAndHealthy == false)
    }

    @Test("isActiveAndHealthy returns false when in grace period")
    func isActiveAndHealthy_returnsFalseWhenInGracePeriod() {
        let status = SubscriptionStatus(
            isSubscribed: true,
            isInGracePeriod: true
        )
        #expect(status.isActiveAndHealthy == false)
    }

    @Test("hasBillingIssues returns true when in billing retry")
    func hasBillingIssues_returnsTrueWhenInBillingRetry() {
        let status = SubscriptionStatus(
            isSubscribed: true,
            isInBillingRetry: true
        )
        #expect(status.hasBillingIssues == true)
    }

    @Test("hasBillingIssues returns true when in grace period")
    func hasBillingIssues_returnsTrueWhenInGracePeriod() {
        let status = SubscriptionStatus(
            isSubscribed: true,
            isInGracePeriod: true
        )
        #expect(status.hasBillingIssues == true)
    }

    @Test("isExpiringSoon returns true when expiring within 3 days and not renewing")
    func isExpiringSoon_returnsTrueWhenExpiringWithin3DaysNotRenewing() {
        let expiresDate = Date().addingTimeInterval(2 * 24 * 60 * 60) // 2 days
        let status = SubscriptionStatus(
            isSubscribed: true,
            expiresDate: expiresDate,
            willRenew: false
        )
        #expect(status.isExpiringSoon == true)
    }

    @Test("isExpiringSoon returns false when will renew")
    func isExpiringSoon_returnsFalseWhenWillRenew() {
        let expiresDate = Date().addingTimeInterval(2 * 24 * 60 * 60) // 2 days
        let status = SubscriptionStatus(
            isSubscribed: true,
            expiresDate: expiresDate,
            willRenew: true
        )
        #expect(status.isExpiringSoon == false)
    }

    @Test("daysUntilExpiration returns correct number of days")
    func daysUntilExpiration_returnsCorrectDays() {
        let daysAhead = 10
        let expiresDate = Date().addingTimeInterval(Double(daysAhead) * 24 * 60 * 60)
        let status = SubscriptionStatus(
            isSubscribed: true,
            expiresDate: expiresDate
        )

        // Allow for slight timing differences
        let days = status.daysUntilExpiration
        #expect(days != nil)
        #expect(days == daysAhead || days == daysAhead - 1)
    }

    @Test("daysUntilExpiration returns nil when no expiration date")
    func daysUntilExpiration_returnsNilWhenNoExpirationDate() {
        let status = SubscriptionStatus(isSubscribed: true)
        #expect(status.daysUntilExpiration == nil)
    }
}
