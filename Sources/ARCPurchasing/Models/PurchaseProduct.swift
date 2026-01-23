//
//  PurchaseProduct.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Provider-agnostic product representation.
///
/// `PurchaseProduct` wraps the native product type from any purchase provider,
/// providing a unified interface for product information across different backends.
///
/// ## Example
///
/// ```swift
/// let products = try await purchaseManager.fetchProducts(for: ["premium_monthly"])
/// for product in products {
///     print("\(product.displayName): \(product.displayPrice)")
/// }
/// ```
public struct PurchaseProduct: Identifiable, Sendable, Equatable {
    // MARK: - Public Properties

    /// Unique product identifier (e.g., "com.arclabs.premium_monthly").
    public let id: String

    /// Localized display name.
    public let displayName: String

    /// Localized product description.
    public let description: String

    /// Price as decimal value.
    public let price: Decimal

    /// Localized price string (e.g., "$9.99").
    public let displayPrice: String

    /// Currency code (e.g., "USD").
    public let currencyCode: String

    /// Product type (consumable, subscription, etc.).
    public let type: ProductType

    /// Subscription period (if subscription).
    public let subscriptionPeriod: SubscriptionPeriod?

    /// Introductory offer (if available).
    public let introductoryOffer: IntroductoryOffer?

    // MARK: - Internal Properties

    /// Original provider product (type-erased).
    ///
    /// Used internally to perform actual purchase operations.
    let underlyingProduct: AnySendable

    // MARK: - Initialization

    /// Creates a new purchase product.
    ///
    /// - Parameters:
    ///   - id: Unique product identifier.
    ///   - displayName: Localized display name.
    ///   - description: Localized description.
    ///   - price: Price as decimal.
    ///   - displayPrice: Localized price string.
    ///   - currencyCode: Currency code.
    ///   - type: Product type.
    ///   - subscriptionPeriod: Subscription period (optional).
    ///   - introductoryOffer: Introductory offer (optional).
    ///   - underlyingProduct: Type-erased provider product.
    public init(
        id: String,
        displayName: String,
        description: String,
        price: Decimal,
        displayPrice: String,
        currencyCode: String,
        type: ProductType,
        subscriptionPeriod: SubscriptionPeriod? = nil,
        introductoryOffer: IntroductoryOffer? = nil,
        underlyingProduct: AnySendable
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.price = price
        self.displayPrice = displayPrice
        self.currencyCode = currencyCode
        self.type = type
        self.subscriptionPeriod = subscriptionPeriod
        self.introductoryOffer = introductoryOffer
        self.underlyingProduct = underlyingProduct
    }

    // MARK: - Equatable

    public static func == (lhs: PurchaseProduct, rhs: PurchaseProduct) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - ProductType

/// The type of in-app purchase product.
public enum ProductType: String, Sendable, Equatable, CaseIterable {
    /// Single-use product that can be purchased multiple times.
    case consumable

    /// One-time purchase that persists forever.
    case nonConsumable

    /// Automatically renewing subscription.
    case autoRenewableSubscription

    /// Subscription that does not auto-renew.
    case nonRenewableSubscription
}

// MARK: - SubscriptionPeriod

/// Represents the billing period for a subscription.
public struct SubscriptionPeriod: Sendable, Equatable {
    /// Number of period units.
    public let value: Int

    /// Period unit (day, week, month, year).
    public let unit: PeriodUnit

    /// Creates a subscription period.
    ///
    /// - Parameters:
    ///   - value: Number of period units.
    ///   - unit: Period unit.
    public init(value: Int, unit: PeriodUnit) {
        self.value = value
        self.unit = unit
    }
}

// MARK: - PeriodUnit

/// Time unit for subscription periods.
public enum PeriodUnit: String, Sendable, Equatable, CaseIterable {
    case day
    case week
    case month
    case year
}

// MARK: - IntroductoryOffer

/// Represents an introductory offer for a subscription product.
public struct IntroductoryOffer: Sendable, Equatable {
    /// Introductory price.
    public let price: Decimal

    /// Localized introductory price string.
    public let displayPrice: String

    /// Period of the introductory offer.
    public let period: SubscriptionPeriod

    /// Payment mode for the offer.
    public let paymentMode: PaymentMode

    /// Creates an introductory offer.
    ///
    /// - Parameters:
    ///   - price: Introductory price.
    ///   - displayPrice: Localized price string.
    ///   - period: Offer period.
    ///   - paymentMode: Payment mode.
    public init(
        price: Decimal,
        displayPrice: String,
        period: SubscriptionPeriod,
        paymentMode: PaymentMode
    ) {
        self.price = price
        self.displayPrice = displayPrice
        self.period = period
        self.paymentMode = paymentMode
    }
}

// MARK: - PaymentMode

/// Payment mode for introductory offers.
public enum PaymentMode: String, Sendable, Equatable, CaseIterable {
    /// Free trial period.
    case freeTrial

    /// Discounted recurring payments.
    case payAsYouGo

    /// Single discounted payment upfront.
    case payUpFront
}

// MARK: - AnySendable

/// Type-erased wrapper for Sendable values.
///
/// Used to store provider-specific product types while maintaining Sendable conformance.
public struct AnySendable: @unchecked Sendable {
    /// The wrapped value.
    public let value: Any

    /// Creates a type-erased sendable wrapper.
    ///
    /// - Parameter value: The value to wrap.
    public init(_ value: Any) {
        self.value = value
    }
}
