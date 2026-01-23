//
//  RevenueCat+Mapping.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import RevenueCat

// MARK: - StoreProduct Mapping

extension StoreProduct {
    /// Converts a RevenueCat `StoreProduct` to ``PurchaseProduct``.
    func toPurchaseProduct() -> PurchaseProduct {
        PurchaseProduct(
            id: productIdentifier,
            displayName: localizedTitle,
            description: localizedDescription,
            price: price as Decimal,
            displayPrice: localizedPriceString,
            currencyCode: currencyCode ?? "USD",
            type: productType.toPurchaseProductType(),
            subscriptionPeriod: subscriptionPeriod?.toPurchaseSubscriptionPeriod(),
            introductoryOffer: introductoryDiscount?.toIntroductoryOffer(),
            underlyingProduct: AnySendable(self)
        )
    }
}

// MARK: - ProductType Mapping

extension StoreProduct.ProductType {
    /// Converts RevenueCat product type to ``ProductType``.
    func toPurchaseProductType() -> ProductType {
        switch self {
        case .consumable:
            return .consumable
        case .nonConsumable:
            return .nonConsumable
        case .autoRenewableSubscription:
            return .autoRenewableSubscription
        case .nonRenewableSubscription:
            return .nonRenewableSubscription
        @unknown default:
            return .nonConsumable
        }
    }
}

// MARK: - SubscriptionPeriod Mapping

extension RevenueCat.SubscriptionPeriod {
    /// Converts RevenueCat subscription period to ``SubscriptionPeriod``.
    func toPurchaseSubscriptionPeriod() -> ARCPurchasing.SubscriptionPeriod {
        ARCPurchasing.SubscriptionPeriod(
            value: value,
            unit: unit.toPurchasePeriodUnit()
        )
    }
}

extension RevenueCat.SubscriptionPeriod.Unit {
    /// Converts RevenueCat period unit to ``PeriodUnit``.
    func toPurchasePeriodUnit() -> PeriodUnit {
        switch self {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .year:
            return .year
        @unknown default:
            return .month
        }
    }
}

// MARK: - IntroductoryOffer Mapping

extension StoreProductDiscount {
    /// Converts RevenueCat discount to ``IntroductoryOffer``.
    func toIntroductoryOffer() -> IntroductoryOffer {
        IntroductoryOffer(
            price: price as Decimal,
            displayPrice: localizedPriceString,
            period: subscriptionPeriod.toPurchaseSubscriptionPeriod(),
            paymentMode: paymentMode.toPaymentMode()
        )
    }
}

extension StoreProductDiscount.PaymentMode {
    /// Converts RevenueCat payment mode to ``PaymentMode``.
    func toPaymentMode() -> PaymentMode {
        switch self {
        case .freeTrial:
            return .freeTrial
        case .payAsYouGo:
            return .payAsYouGo
        case .payUpFront:
            return .payUpFront
        @unknown default:
            return .payUpFront
        }
    }
}

// MARK: - Transaction Mapping

extension StoreTransaction {
    /// Converts RevenueCat transaction to ``PurchaseTransaction``.
    func toPurchaseTransaction() -> PurchaseTransaction {
        PurchaseTransaction(
            id: transactionIdentifier,
            productID: productIdentifier,
            originalTransactionID: nil,
            purchaseDate: purchaseDate,
            expiresDate: nil,
            isRestored: false
        )
    }
}

// MARK: - Entitlement Mapping

extension EntitlementInfo {
    /// Converts RevenueCat entitlement info to ``Entitlement``.
    func toEntitlement() -> Entitlement {
        Entitlement(
            id: identifier,
            isActive: isActive,
            productIdentifier: productIdentifier,
            expiresDate: expirationDate,
            willRenew: willRenew,
            periodType: periodType.toEntitlementPeriodType()
        )
    }
}

extension RevenueCat.PeriodType {
    /// Converts RevenueCat period type to ``EntitlementPeriodType``.
    func toEntitlementPeriodType() -> EntitlementPeriodType {
        switch self {
        case .normal:
            return .normal
        case .trial:
            return .trial
        case .intro:
            return .intro
        case .prepaid:
            return .normal
        @unknown default:
            return .normal
        }
    }
}

// MARK: - CustomerInfo Mapping

extension CustomerInfo {
    /// Converts RevenueCat customer info to ``SubscriptionStatus``.
    func toSubscriptionStatus() -> SubscriptionStatus {
        let activeSubscriptions = activeSubscriptions
        let isSubscribed = !activeSubscriptions.isEmpty

        // Find the active entitlement with the latest expiration
        let activeEntitlement = entitlements.active.values.first

        return SubscriptionStatus(
            isSubscribed: isSubscribed,
            activeProductID: activeEntitlement?.productIdentifier,
            expiresDate: activeEntitlement?.expirationDate,
            willRenew: activeEntitlement?.willRenew ?? false,
            isInBillingRetry: activeEntitlement?.billingIssueDetectedAt != nil,
            isInGracePeriod: false,
            managementURL: managementURL
        )
    }
}
