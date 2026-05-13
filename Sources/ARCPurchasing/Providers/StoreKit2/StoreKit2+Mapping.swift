//
//  StoreKit2+Mapping.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import Foundation
import StoreKit

// MARK: - Product → PurchaseProduct

extension Product {
    /// Converts a native StoreKit 2 `Product` to ``PurchaseProduct``.
    func toPurchaseProduct() -> PurchaseProduct {
        PurchaseProduct(id: id,
                        displayName: displayName,
                        description: description,
                        price: price,
                        displayPrice: displayPrice,
                        currencyCode: priceFormatStyle.currencyCode,
                        type: type.toPurchaseProductType(),
                        subscriptionPeriod: subscription?.subscriptionPeriod.toPurchaseSubscriptionPeriod(),
                        introductoryOffer: subscription?.introductoryOffer?.toIntroductoryOffer(),
                        underlyingProduct: AnySendable(self))
    }
}

// MARK: - ProductType Mapping

extension Product.ProductType {
    /// Converts native StoreKit 2 product type to ``ProductType``.
    func toPurchaseProductType() -> ProductType {
        switch self {
        case .consumable:
            .consumable
        case .nonConsumable:
            .nonConsumable
        case .autoRenewable:
            .autoRenewableSubscription
        case .nonRenewable:
            .nonRenewableSubscription
        default:
            .nonConsumable
        }
    }
}

// MARK: - SubscriptionPeriod Mapping

extension Product.SubscriptionPeriod {
    /// Converts native StoreKit 2 subscription period to ``SubscriptionPeriod``.
    func toPurchaseSubscriptionPeriod() -> SubscriptionPeriod {
        SubscriptionPeriod(value: value, unit: unit.toPurchasePeriodUnit())
    }
}

extension Product.SubscriptionPeriod.Unit {
    /// Converts native StoreKit 2 period unit to ``PeriodUnit``.
    func toPurchasePeriodUnit() -> PeriodUnit {
        switch self {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default: .month
        }
    }
}

// MARK: - IntroductoryOffer Mapping

extension Product.SubscriptionOffer {
    /// Converts a native StoreKit 2 subscription offer to ``IntroductoryOffer``.
    func toIntroductoryOffer() -> IntroductoryOffer {
        IntroductoryOffer(price: price,
                          displayPrice: displayPrice,
                          period: period.toPurchaseSubscriptionPeriod(),
                          paymentMode: paymentMode.toPaymentMode())
    }
}

extension Product.SubscriptionOffer.PaymentMode {
    /// Converts native StoreKit 2 payment mode to ``PaymentMode``.
    func toPaymentMode() -> PaymentMode {
        switch self {
        case .freeTrial: .freeTrial
        case .payAsYouGo: .payAsYouGo
        case .payUpFront: .payUpFront
        default: .payUpFront
        }
    }
}
