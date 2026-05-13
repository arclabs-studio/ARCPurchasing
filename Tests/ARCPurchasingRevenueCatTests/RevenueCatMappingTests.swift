//
//  RevenueCatMappingTests.swift
//  ARCPurchasingRevenueCatTests
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import ARCPurchasing
import RevenueCat
import Testing
@testable import ARCPurchasingRevenueCat

// MARK: - ProductType Mapping

struct ProductTypeMappingTests {
    @Test("consumable maps correctly") func consumable() {
        #expect(StoreProduct.ProductType.consumable.toPurchaseProductType() == .consumable)
    }

    @Test("nonConsumable maps correctly") func nonConsumable() {
        #expect(StoreProduct.ProductType.nonConsumable.toPurchaseProductType() == .nonConsumable)
    }

    @Test("autoRenewableSubscription maps correctly") func autoRenewable() {
        #expect(StoreProduct.ProductType.autoRenewableSubscription
            .toPurchaseProductType() == .autoRenewableSubscription)
    }

    @Test("nonRenewableSubscription maps correctly") func nonRenewable() {
        #expect(StoreProduct.ProductType.nonRenewableSubscription.toPurchaseProductType() == .nonRenewableSubscription)
    }
}

// MARK: - PeriodUnit Mapping

struct PeriodUnitMappingTests {
    @Test("day maps correctly") func day() {
        #expect(RevenueCat.SubscriptionPeriod.Unit.day.toPurchasePeriodUnit() == .day)
    }

    @Test("week maps correctly") func week() {
        #expect(RevenueCat.SubscriptionPeriod.Unit.week.toPurchasePeriodUnit() == .week)
    }

    @Test("month maps correctly") func month() {
        #expect(RevenueCat.SubscriptionPeriod.Unit.month.toPurchasePeriodUnit() == .month)
    }

    @Test("year maps correctly") func year() {
        #expect(RevenueCat.SubscriptionPeriod.Unit.year.toPurchasePeriodUnit() == .year)
    }
}

// MARK: - PaymentMode Mapping

struct PaymentModeMappingTests {
    @Test("freeTrial maps correctly") func freeTrial() {
        #expect(StoreProductDiscount.PaymentMode.freeTrial.toPaymentMode() == .freeTrial)
    }

    @Test("payAsYouGo maps correctly") func payAsYouGo() {
        #expect(StoreProductDiscount.PaymentMode.payAsYouGo.toPaymentMode() == .payAsYouGo)
    }

    @Test("payUpFront maps correctly") func payUpFront() {
        #expect(StoreProductDiscount.PaymentMode.payUpFront.toPaymentMode() == .payUpFront)
    }
}

// MARK: - PeriodType Mapping

struct PeriodTypeMappingTests {
    @Test("normal maps correctly") func normal() {
        #expect(RevenueCat.PeriodType.normal.toEntitlementPeriodType() == .normal)
    }

    @Test("trial maps correctly") func trial() {
        #expect(RevenueCat.PeriodType.trial.toEntitlementPeriodType() == .trial)
    }

    @Test("intro maps correctly") func intro() {
        #expect(RevenueCat.PeriodType.intro.toEntitlementPeriodType() == .intro)
    }

    @Test("prepaid falls back to normal") func prepaid() {
        // prepaid has no ARCPurchasing equivalent; normalised to .normal
        #expect(RevenueCat.PeriodType.prepaid.toEntitlementPeriodType() == .normal)
    }
}

// MARK: - SubscriptionPeriod Mapping

struct SubscriptionPeriodMappingTests {
    @Test("value and unit are preserved") func valueAndUnit() {
        let rcPeriod = RevenueCat.SubscriptionPeriod(value: 3, unit: .month)
        let mapped = rcPeriod.toPurchaseSubscriptionPeriod()

        #expect(mapped.value == 3)
        #expect(mapped.unit == .month)
    }

    @Test("annual period maps correctly") func annual() {
        let rcPeriod = RevenueCat.SubscriptionPeriod(value: 1, unit: .year)
        let mapped = rcPeriod.toPurchaseSubscriptionPeriod()

        #expect(mapped.value == 1)
        #expect(mapped.unit == .year)
    }

    @Test("weekly period maps correctly") func weekly() {
        let rcPeriod = RevenueCat.SubscriptionPeriod(value: 2, unit: .week)
        let mapped = rcPeriod.toPurchaseSubscriptionPeriod()

        #expect(mapped.value == 2)
        #expect(mapped.unit == .week)
    }
}
