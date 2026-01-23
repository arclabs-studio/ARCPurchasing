//
//  TestHelpers.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
@testable import ARCPurchasing

// MARK: - PurchaseProduct Mock Factory

extension PurchaseProduct {
    /// Creates a mock purchase product for testing.
    ///
    /// - Parameters:
    ///   - id: Product identifier.
    ///   - displayName: Display name.
    ///   - price: Product price.
    ///   - type: Product type.
    /// - Returns: A mock ``PurchaseProduct``.
    static func mock(
        id: String = "com.test.product",
        displayName: String = "Test Product",
        description: String = "Test description",
        price: Decimal = 4.99,
        displayPrice: String = "$4.99",
        currencyCode: String = "USD",
        type: ProductType = .nonConsumable,
        subscriptionPeriod: SubscriptionPeriod? = nil,
        introductoryOffer: IntroductoryOffer? = nil
    ) -> PurchaseProduct {
        PurchaseProduct(
            id: id,
            displayName: displayName,
            description: description,
            price: price,
            displayPrice: displayPrice,
            currencyCode: currencyCode,
            type: type,
            subscriptionPeriod: subscriptionPeriod,
            introductoryOffer: introductoryOffer,
            underlyingProduct: AnySendable("mock")
        )
    }

    /// Creates a mock subscription product.
    static func mockSubscription(
        id: String = "com.test.subscription.monthly",
        displayName: String = "Premium Monthly",
        price: Decimal = 9.99,
        periodValue: Int = 1,
        periodUnit: PeriodUnit = .month
    ) -> PurchaseProduct {
        PurchaseProduct.mock(
            id: id,
            displayName: displayName,
            price: price,
            displayPrice: "$\(price)",
            type: .autoRenewableSubscription,
            subscriptionPeriod: SubscriptionPeriod(value: periodValue, unit: periodUnit)
        )
    }
}

// MARK: - PurchaseTransaction Mock Factory

extension PurchaseTransaction {
    /// Creates a mock purchase transaction for testing.
    static func mock(
        id: String = "txn_123",
        productID: String = "com.test.product",
        purchaseDate: Date = Date(),
        price: Decimal? = 4.99,
        currencyCode: String? = "USD"
    ) -> PurchaseTransaction {
        PurchaseTransaction(
            id: id,
            productID: productID,
            originalTransactionID: nil,
            purchaseDate: purchaseDate,
            expiresDate: nil,
            isRestored: false,
            price: price,
            currencyCode: currencyCode
        )
    }
}

// MARK: - Entitlement Mock Factory

extension Entitlement {
    /// Creates a mock entitlement for testing.
    static func mock(
        id: String = "premium",
        isActive: Bool = true,
        productIdentifier: String? = "com.test.premium",
        expiresDate: Date? = nil,
        willRenew: Bool = true,
        periodType: EntitlementPeriodType = .normal
    ) -> Entitlement {
        Entitlement(
            id: id,
            isActive: isActive,
            productIdentifier: productIdentifier,
            expiresDate: expiresDate,
            willRenew: willRenew,
            periodType: periodType
        )
    }
}

// MARK: - SubscriptionStatus Mock Factory

extension SubscriptionStatus {
    /// Creates a mock subscription status for testing.
    static func mock(
        isSubscribed: Bool = true,
        activeProductID: String? = "com.test.subscription.monthly",
        expiresDate: Date? = Date().addingTimeInterval(30 * 24 * 60 * 60),
        willRenew: Bool = true
    ) -> SubscriptionStatus {
        SubscriptionStatus(
            isSubscribed: isSubscribed,
            activeProductID: activeProductID,
            expiresDate: expiresDate,
            willRenew: willRenew,
            isInBillingRetry: false,
            isInGracePeriod: false,
            managementURL: nil
        )
    }
}

// MARK: - PurchaseConfiguration Mock Factory

extension PurchaseConfiguration {
    /// Creates a mock configuration for testing.
    static func mock(
        apiKey: String = "test_api_key",
        userID: String? = nil,
        entitlementIdentifiers: Set<String> = ["premium"]
    ) -> PurchaseConfiguration {
        PurchaseConfiguration(
            apiKey: apiKey,
            userID: userID,
            debugLoggingEnabled: true,
            storeKitVersion: .storeKit2,
            entitlementIdentifiers: entitlementIdentifiers
        )
    }
}
