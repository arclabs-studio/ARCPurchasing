//
//  StoreKit2MappingTests.swift
//  ARCPurchasingTests
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import StoreKit
import Testing
@testable import ARCPurchasing

// MARK: - ProductType Mapping

struct StoreKit2ProductTypeMappingTests {
    @Test("consumable maps correctly") func consumable() {
        #expect(Product.ProductType.consumable.toPurchaseProductType() == .consumable)
    }

    @Test("nonConsumable maps correctly") func nonConsumable() {
        #expect(Product.ProductType.nonConsumable.toPurchaseProductType() == .nonConsumable)
    }

    @Test("autoRenewable maps to autoRenewableSubscription") func autoRenewable() {
        #expect(Product.ProductType.autoRenewable.toPurchaseProductType() == .autoRenewableSubscription)
    }

    @Test("nonRenewable maps to nonRenewableSubscription") func nonRenewable() {
        #expect(Product.ProductType.nonRenewable.toPurchaseProductType() == .nonRenewableSubscription)
    }
}

// MARK: - PeriodUnit Mapping

struct StoreKit2PeriodUnitMappingTests {
    @Test("day maps correctly") func day() {
        #expect(Product.SubscriptionPeriod.Unit.day.toPurchasePeriodUnit() == .day)
    }

    @Test("week maps correctly") func week() {
        #expect(Product.SubscriptionPeriod.Unit.week.toPurchasePeriodUnit() == .week)
    }

    @Test("month maps correctly") func month() {
        #expect(Product.SubscriptionPeriod.Unit.month.toPurchasePeriodUnit() == .month)
    }

    @Test("year maps correctly") func year() {
        #expect(Product.SubscriptionPeriod.Unit.year.toPurchasePeriodUnit() == .year)
    }
}

// MARK: - PaymentMode Mapping

struct StoreKit2PaymentModeMappingTests {
    @Test("freeTrial maps correctly") func freeTrial() {
        #expect(Product.SubscriptionOffer.PaymentMode.freeTrial.toPaymentMode() == .freeTrial)
    }

    @Test("payAsYouGo maps correctly") func payAsYouGo() {
        #expect(Product.SubscriptionOffer.PaymentMode.payAsYouGo.toPaymentMode() == .payAsYouGo)
    }

    @Test("payUpFront maps correctly") func payUpFront() {
        #expect(Product.SubscriptionOffer.PaymentMode.payUpFront.toPaymentMode() == .payUpFront)
    }
}
