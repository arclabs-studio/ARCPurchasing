//
//  PurchaseProductTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Testing
@testable import ARCPurchasing

@Suite("PurchaseProduct Tests")
struct PurchaseProductTests {
    // MARK: - Initialization Tests

    @Test("Initialization sets all properties correctly")
    func initialization_setsAllProperties() {
        // Arrange & Act
        let product = PurchaseProduct(
            id: "com.arclabs.premium",
            displayName: "Premium",
            description: "Unlock all features",
            price: 9.99,
            displayPrice: "$9.99",
            currencyCode: "USD",
            type: .autoRenewableSubscription,
            subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .month),
            introductoryOffer: nil,
            underlyingProduct: AnySendable("mock")
        )

        // Assert
        #expect(product.id == "com.arclabs.premium")
        #expect(product.displayName == "Premium")
        #expect(product.description == "Unlock all features")
        #expect(product.price == 9.99)
        #expect(product.displayPrice == "$9.99")
        #expect(product.currencyCode == "USD")
        #expect(product.type == .autoRenewableSubscription)
        #expect(product.subscriptionPeriod?.value == 1)
        #expect(product.subscriptionPeriod?.unit == .month)
        #expect(product.introductoryOffer == nil)
    }

    @Test("Products with same ID are equal")
    func productsWithSameID_areEqual() {
        // Arrange
        let product1 = PurchaseProduct.mock(id: "test.product")
        let product2 = PurchaseProduct.mock(id: "test.product", displayName: "Different Name")

        // Assert
        #expect(product1 == product2)
    }

    @Test("Products with different IDs are not equal")
    func productsWithDifferentID_areNotEqual() {
        // Arrange
        let product1 = PurchaseProduct.mock(id: "test.product.1")
        let product2 = PurchaseProduct.mock(id: "test.product.2")

        // Assert
        #expect(product1 != product2)
    }

    // MARK: - ProductType Tests

    @Test("ProductType has all expected cases")
    func productType_hasAllCases() {
        let allCases = ProductType.allCases

        #expect(allCases.count == 4)
        #expect(allCases.contains(.consumable))
        #expect(allCases.contains(.nonConsumable))
        #expect(allCases.contains(.autoRenewableSubscription))
        #expect(allCases.contains(.nonRenewableSubscription))
    }

    // MARK: - SubscriptionPeriod Tests

    @Test("SubscriptionPeriod equality works correctly")
    func subscriptionPeriod_equalityWorks() {
        let period1 = SubscriptionPeriod(value: 1, unit: .month)
        let period2 = SubscriptionPeriod(value: 1, unit: .month)
        let period3 = SubscriptionPeriod(value: 1, unit: .year)

        #expect(period1 == period2)
        #expect(period1 != period3)
    }

    // MARK: - IntroductoryOffer Tests

    @Test("IntroductoryOffer initialization works correctly")
    func introductoryOffer_initializesCorrectly() {
        let offer = IntroductoryOffer(
            price: 0,
            displayPrice: "Free",
            period: SubscriptionPeriod(value: 7, unit: .day),
            paymentMode: .freeTrial
        )

        #expect(offer.price == 0)
        #expect(offer.displayPrice == "Free")
        #expect(offer.period.value == 7)
        #expect(offer.period.unit == .day)
        #expect(offer.paymentMode == .freeTrial)
    }
}
