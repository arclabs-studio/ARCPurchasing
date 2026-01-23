//
//  EntitlementTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

@Suite("Entitlement Tests")
struct EntitlementTests {
    // MARK: - Initialization Tests

    @Test("Initialization sets all properties correctly")
    func initialization_setsAllProperties() {
        // Arrange
        let expiresDate = Date().addingTimeInterval(30 * 24 * 60 * 60)

        // Act
        let entitlement = Entitlement(
            id: "premium",
            isActive: true,
            productIdentifier: "com.app.premium.monthly",
            expiresDate: expiresDate,
            willRenew: true,
            periodType: .normal
        )

        // Assert
        #expect(entitlement.id == "premium")
        #expect(entitlement.isActive == true)
        #expect(entitlement.productIdentifier == "com.app.premium.monthly")
        #expect(entitlement.expiresDate == expiresDate)
        #expect(entitlement.willRenew == true)
        #expect(entitlement.periodType == .normal)
    }

    // MARK: - Convenience Property Tests

    @Test("isInTrial returns true for trial period")
    func isInTrial_returnsTrueForTrialPeriod() {
        let entitlement = Entitlement.mock(periodType: .trial)
        #expect(entitlement.isInTrial == true)
    }

    @Test("isInTrial returns false for normal period")
    func isInTrial_returnsFalseForNormalPeriod() {
        let entitlement = Entitlement.mock(periodType: .normal)
        #expect(entitlement.isInTrial == false)
    }

    @Test("isInIntro returns true for intro period")
    func isInIntro_returnsTrueForIntroPeriod() {
        let entitlement = Entitlement.mock(periodType: .intro)
        #expect(entitlement.isInIntro == true)
    }

    @Test("isExpiringSoon returns true when expiring within 7 days")
    func isExpiringSoon_returnsTrueWhenExpiringWithin7Days() {
        let expiresDate = Date().addingTimeInterval(3 * 24 * 60 * 60) // 3 days
        let entitlement = Entitlement.mock(expiresDate: expiresDate)
        #expect(entitlement.isExpiringSoon == true)
    }

    @Test("isExpiringSoon returns false when expiring after 7 days")
    func isExpiringSoon_returnsFalseWhenExpiringAfter7Days() {
        let expiresDate = Date().addingTimeInterval(14 * 24 * 60 * 60) // 14 days
        let entitlement = Entitlement.mock(expiresDate: expiresDate)
        #expect(entitlement.isExpiringSoon == false)
    }

    @Test("isExpiringSoon returns false when no expiration date")
    func isExpiringSoon_returnsFalseWhenNoExpirationDate() {
        let entitlement = Entitlement.mock(expiresDate: nil)
        #expect(entitlement.isExpiringSoon == false)
    }

    // MARK: - Equatable Tests

    @Test("Entitlements with same ID are equal")
    func entitlementsWithSameID_areEqual() {
        let entitlement1 = Entitlement.mock(id: "premium")
        let entitlement2 = Entitlement.mock(id: "premium")
        #expect(entitlement1 == entitlement2)
    }

    @Test("Entitlements with different IDs are not equal")
    func entitlementsWithDifferentID_areNotEqual() {
        let entitlement1 = Entitlement.mock(id: "premium")
        let entitlement2 = Entitlement.mock(id: "pro")
        #expect(entitlement1 != entitlement2)
    }
}
