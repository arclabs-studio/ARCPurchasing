//
//  PaywallLocalizedCopyTests.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import ARCPurchasing
import Foundation
import Testing
@testable import ARCPurchasingUI

/// Pins the localization keys the paywall emits for its pricing chrome.
///
/// The package ships no string catalog: these keys are the contract with the consuming
/// app's `Localizable.xcstrings`, so the expectation table is written out literally.
/// Deriving it from the implementation would restate the code instead of checking it —
/// and would not notice a key rename that silently unlocalizes every consumer.
struct PaywallLocalizedCopyTests {
    // MARK: - Fixtures

    private static func makeProduct(period: SubscriptionPeriod?,
                                    price: Decimal = 34.99,
                                    displayName: String = "Yearly",
                                    currencyCode: String = "USD") -> PurchaseProduct {
        PurchaseProduct(id: "product",
                        displayName: displayName,
                        description: "",
                        price: price,
                        displayPrice: "$\(price)",
                        currencyCode: currencyCode,
                        type: .autoRenewableSubscription,
                        subscriptionPeriod: period)
    }

    private static func localizedKey(_ copy: PaywallCopy?) -> String? {
        guard case let .localized(resource) = copy else { return nil }
        return resource.key
    }

    private static func verbatimValue(_ copy: PaywallCopy?) -> String? {
        guard case let .verbatim(value) = copy else { return nil }
        return value
    }

    // MARK: - Oracle

    private static func period(_ value: Int, _ unit: PeriodUnit) -> SubscriptionPeriod {
        SubscriptionPeriod(value: value, unit: unit)
    }

    static let periodKeys: [(SubscriptionPeriod, String)] = [(period(1, .month), "MONTHLY"),
                                                             (period(1, .year), "YEARLY"),
                                                             (period(12, .month), "YEARLY"),
                                                             (period(3, .month), "QUARTERLY"),
                                                             (period(6, .month), "6 MONTHS"),
                                                             (period(2, .month), "%lld MONTHS"),
                                                             (period(1, .day), "DAY"),
                                                             (period(10, .day), "%lld DAYS"),
                                                             (period(1, .week), "WEEK"),
                                                             (period(2, .week), "%lld WEEKS"),
                                                             (period(2, .year), "%lld YEARS")]

    // MARK: - Period Label

    @Test("Every billing period emits its expected localization key",
          arguments: PaywallLocalizedCopyTests.periodKeys)
    func periodKey(period: SubscriptionPeriod, expected: String) {
        // Given a product with a billing period / When its period copy is derived
        let copy = Self.makeProduct(period: period).paywallPeriodCopy

        // Then the copy is a key the consuming app can translate
        #expect(Self.localizedKey(copy) == expected)
    }

    @Test("A product without a billing period falls back to its store name, verbatim") func periodFallbackIsVerbatim() {
        // Given a product the store gave no subscription period
        let product = Self.makeProduct(period: nil, displayName: "Lifetime Access")

        // When its period copy is derived / Then the store's own name is not treated as a key
        #expect(Self.verbatimValue(product.paywallPeriodCopy) == "LIFETIME ACCESS")
    }

    // MARK: - Bottom Label

    @Test("A monthly plan emits the plain per-month key") func monthlyBottomKey() {
        // Given a one-month plan
        let product = Self.makeProduct(period: SubscriptionPeriod(value: 1, unit: .month), price: 4.99)

        // When the bottom copy is derived / Then it carries no argument
        #expect(Self.localizedKey(product.paywallBottomCopy) == "per month")
    }

    @Test("A multi-month plan passes the monthly equivalent as an argument, not a fragment")
    func monthlyEquivalentBottomKey() {
        // Given a yearly plan
        let product = Self.makeProduct(period: SubscriptionPeriod(value: 1, unit: .year))

        // When the bottom copy is derived / Then the price is an argument the translation can move
        #expect(Self.localizedKey(product.paywallBottomCopy) == "%@/month")
    }

    @Test("A product without a billing period has no bottom label") func noBottomLabelWithoutPeriod() {
        // Given a product with no subscription period / When the bottom copy is derived
        let copy = Self.makeProduct(period: nil).paywallBottomCopy

        // Then there is nothing to show
        #expect(copy == nil)
    }

    // MARK: - Badges

    @Test("An auto-calculated savings badge emits the savings key") func savingsBadgeKey() {
        // Given an auto-calculated badge / When its copy is derived
        let copy = PaywallBadge.savings(42).copy

        // Then the percentage is an argument of a translatable key
        #expect(Self.localizedKey(copy) == "SAVE %lld%%")
    }

    @Test("An app-supplied badge override passes through verbatim") func customBadgeIsVerbatim() {
        // Given a badge the app configured itself / When its copy is derived
        let copy = PaywallBadge.custom("AHORRA 42%").copy

        // Then it is rendered as given — the app already localized it
        #expect(Self.verbatimValue(copy) == "AHORRA 42%")
    }
}
