//
//  PurchaseConfiguration.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// StoreKit version preference for RevenueCat.
///
/// RevenueCat-specific knob that selects which underlying StoreKit version
/// the RevenueCat SDK uses internally. Has no effect on the native
/// StoreKit 2 provider.
public enum StoreKitVersion: Sendable {
    /// Use StoreKit 1
    case storeKit1
    /// Use StoreKit 2 (recommended for iOS 15+)
    case storeKit2
}

/// StoreKit 2-specific configuration payload.
///
/// Encapsulates settings that only apply to the native StoreKit 2 provider:
/// product IDs to load, optional logical offering groupings, optional
/// `appAccountToken` provider for backend correlation, and an optional
/// entitlement mapper that groups product IDs into logical entitlements.
public struct StoreKit2Configuration: Sendable {
    /// Product identifiers to load from the App Store.
    public let productIDs: Set<String>

    /// Optional offerings map. Keys are offering identifiers; values are the
    /// product IDs included in each offering.
    ///
    /// When `nil`, ``StoreKit2Configuration/productIDs`` is exposed as a
    /// single `"default"` offering.
    public let offerings: [String: Set<String>]?

    /// Optional closure that returns an `appAccountToken` for purchases.
    ///
    /// Forwarded as `Product.PurchaseOption.appAccountToken(_:)` on every
    /// purchase. The same UUID is then returned by the App Store in
    /// renewal info and subsequent transactions, letting your backend
    /// correlate purchases with user accounts.
    public let appAccountTokenProvider: (@Sendable () -> UUID?)?

    /// Maps a product ID to a logical entitlement identifier.
    ///
    /// Default behavior (when `nil`) keys ``Entitlement/id`` by the
    /// underlying product ID. Set this to group multiple product IDs
    /// (e.g., monthly + yearly subscriptions) under a single logical
    /// entitlement like `"premium"`.
    public let entitlementMapper: (@Sendable (_ productID: String) -> String)?

    /// Creates a StoreKit 2 configuration payload.
    public init(productIDs: Set<String>,
                offerings: [String: Set<String>]? = nil,
                appAccountTokenProvider: (@Sendable () -> UUID?)? = nil,
                entitlementMapper: (@Sendable (String) -> String)? = nil) {
        self.productIDs = productIDs
        self.offerings = offerings
        self.appAccountTokenProvider = appAccountTokenProvider
        self.entitlementMapper = entitlementMapper
    }
}

/// Configuration for the purchase provider.
///
/// `PurchaseConfiguration` contains all settings needed to initialize
/// a purchase provider. The same struct serves both backends:
///
/// - For RevenueCat: construct via ``init(apiKey:userID:debugLoggingEnabled:storeKitVersion:entitlementIdentifiers:)``.
/// - For StoreKit 2: construct via
///   ``init(productIDs:userID:debugLoggingEnabled:entitlementIdentifiers:offerings:appAccountTokenProvider:entitlementMapper:)``.
///
/// ## Example — RevenueCat
///
/// ```swift
/// let config = PurchaseConfiguration(
///     apiKey: "your_revenuecat_api_key",
///     entitlementIdentifiers: ["premium", "pro"]
/// )
/// try await ARCPurchaseManager.shared.configure(with: config)
/// ```
///
/// ## Example — StoreKit 2
///
/// ```swift
/// let config = PurchaseConfiguration(
///     productIDs: ["com.app.monthly", "com.app.yearly"],
///     entitlementIdentifiers: ["premium"]
/// )
/// try await ARCPurchaseManager.shared.configure(
///     with: config,
///     provider: StoreKit2ProviderFactory.make()
/// )
/// ```
public struct PurchaseConfiguration: Sendable {
    // MARK: - Shared Properties

    /// Optional user ID to identify on configuration.
    public let userID: String?

    /// Whether to enable debug logging.
    public let debugLoggingEnabled: Bool

    /// Entitlement identifiers to track.
    public let entitlementIdentifiers: Set<String>

    // MARK: - RevenueCat Properties

    /// API key for the RevenueCat provider.
    ///
    /// Empty for StoreKit 2 configurations.
    public let apiKey: String

    /// StoreKit version preference (RevenueCat specific).
    ///
    /// Selects which underlying StoreKit version the RevenueCat SDK uses.
    /// Ignored by the native StoreKit 2 provider.
    public let storeKitVersion: StoreKitVersion

    // MARK: - StoreKit 2 Properties

    /// StoreKit 2-specific configuration. `nil` for RevenueCat configurations.
    public let storeKit2: StoreKit2Configuration?

    // MARK: - Initialization (RevenueCat)

    /// Creates a RevenueCat-flavored purchase configuration.
    ///
    /// - Parameters:
    ///   - apiKey: RevenueCat API key.
    ///   - userID: Optional user ID for identification.
    ///   - debugLoggingEnabled: Enable debug logging (default: `false`).
    ///   - storeKitVersion: StoreKit version to use (default: `.storeKit2`).
    ///   - entitlementIdentifiers: Set of entitlement IDs to track.
    public init(apiKey: String,
                userID: String? = nil,
                debugLoggingEnabled: Bool = false,
                storeKitVersion: StoreKitVersion = .storeKit2,
                entitlementIdentifiers: Set<String> = []) {
        self.apiKey = apiKey
        self.userID = userID
        self.debugLoggingEnabled = debugLoggingEnabled
        self.storeKitVersion = storeKitVersion
        self.entitlementIdentifiers = entitlementIdentifiers
        storeKit2 = nil
    }

    // MARK: - Initialization (StoreKit 2)

    /// Creates a StoreKit 2-flavored purchase configuration.
    ///
    /// - Parameters:
    ///   - productIDs: Product identifiers to load from the App Store.
    ///   - userID: Optional user ID. Hashed into a deterministic
    ///     `appAccountToken` by the StoreKit 2 provider.
    ///   - debugLoggingEnabled: Enable debug logging (default: `false`).
    ///   - entitlementIdentifiers: Set of entitlement IDs to track.
    ///   - offerings: Optional offerings map. Keys are offering identifiers;
    ///     values are the product IDs in each offering.
    ///   - appAccountTokenProvider: Optional closure returning an
    ///     `appAccountToken` used for every purchase.
    ///   - entitlementMapper: Optional closure mapping a product ID to a
    ///     logical entitlement identifier.
    public init(productIDs: Set<String>,
                userID: String? = nil,
                debugLoggingEnabled: Bool = false,
                entitlementIdentifiers: Set<String> = [],
                offerings: [String: Set<String>]? = nil,
                appAccountTokenProvider: (@Sendable () -> UUID?)? = nil,
                entitlementMapper: (@Sendable (String) -> String)? = nil) {
        apiKey = ""
        self.userID = userID
        self.debugLoggingEnabled = debugLoggingEnabled
        storeKitVersion = .storeKit2
        self.entitlementIdentifiers = entitlementIdentifiers
        storeKit2 = StoreKit2Configuration(productIDs: productIDs,
                                           offerings: offerings,
                                           appAccountTokenProvider: appAccountTokenProvider,
                                           entitlementMapper: entitlementMapper)
    }
}

// MARK: - Validation

public extension PurchaseConfiguration {
    /// Validates the configuration.
    ///
    /// Branches on whether ``storeKit2`` is set:
    /// - StoreKit 2: requires non-empty ``StoreKit2Configuration/productIDs``.
    /// - RevenueCat: requires non-empty ``apiKey``.
    ///
    /// - Throws: ``PurchaseError/invalidAPIKey`` if API key is empty (RC path),
    ///           or ``PurchaseError/invalidAPIKey`` if `productIDs` is empty (SK2 path).
    func validate() throws {
        if let sk2 = storeKit2 {
            guard !sk2.productIDs.isEmpty else {
                throw PurchaseError.invalidAPIKey
            }
            return
        }

        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PurchaseError.invalidAPIKey
        }
    }
}
