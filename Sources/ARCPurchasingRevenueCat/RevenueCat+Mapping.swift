//
//  RevenueCat+Mapping.swift
//  ARCPurchasingRevenueCat
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCPurchasing
import Foundation
import RevenueCat

// MARK: - StoreProduct Mapping

extension StoreProduct {
    /// Converts a RevenueCat `StoreProduct` to ``PurchaseProduct``.
    func toPurchaseProduct() -> PurchaseProduct {
        PurchaseProduct(id: productIdentifier,
                        displayName: localizedTitle,
                        description: localizedDescription,
                        price: price as Decimal,
                        displayPrice: localizedPriceString,
                        currencyCode: currencyCode ?? "USD",
                        type: productType.toPurchaseProductType(),
                        subscriptionPeriod: subscriptionPeriod?.toPurchaseSubscriptionPeriod(),
                        introductoryOffer: introductoryDiscount?.toIntroductoryOffer(),
                        underlyingProduct: AnySendable(self))
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
        ARCPurchasing.SubscriptionPeriod(value: value,
                                         unit: unit.toPurchasePeriodUnit())
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
        IntroductoryOffer(price: price as Decimal,
                          displayPrice: localizedPriceString,
                          period: subscriptionPeriod.toPurchaseSubscriptionPeriod(),
                          paymentMode: paymentMode.toPaymentMode())
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

// MARK: - Entitlement Mapping

extension EntitlementInfo {
    /// Converts RevenueCat entitlement info to ``Entitlement``.
    ///
    /// - Parameter mapper: Optional closure that overrides the
    ///   entitlement identifier based on the product identifier. When
    ///   `nil`, the RevenueCat entitlement identifier is used as-is.
    func toEntitlement(mapper: (@Sendable (String) -> String)? = nil) -> Entitlement {
        let entitlementID = mapper?(productIdentifier) ?? identifier
        return Entitlement(id: entitlementID,
                           isActive: isActive,
                           productIdentifier: productIdentifier,
                           expiresDate: expirationDate,
                           willRenew: willRenew,
                           periodType: periodType.toEntitlementPeriodType())
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
    ///
    /// - Parameter configuredEntitlementIdentifiers: Entitlement
    ///   identifiers the app tracks (from
    ///   ``PurchaseConfiguration/entitlementIdentifiers``). Any active
    ///   entitlement in this set counts as subscribed — covering
    ///   promotional grants and lifetime purchases that never appear in
    ///   `activeSubscriptions`. Empty set preserves legacy
    ///   subscriptions-only behavior.
    func toSubscriptionStatus(configuredEntitlementIdentifiers: Set<String> = []) -> SubscriptionStatus {
        let snapshots = entitlements.active.values.map {
            ActiveEntitlementSnapshot(identifier: $0.identifier,
                                      productIdentifier: $0.productIdentifier,
                                      expirationDate: $0.expirationDate,
                                      willRenew: $0.willRenew,
                                      billingIssueDetectedAt: $0.billingIssueDetectedAt)
        }

        return SubscriptionStatusResolver.resolve(activeSubscriptions: activeSubscriptions,
                                                  activeEntitlements: snapshots,
                                                  configuredIdentifiers: configuredEntitlementIdentifiers,
                                                  managementURL: managementURL)
    }
}
