//
//  RevenueCatProviderFactory.swift
//  ARCPurchasingRevenueCat
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import ARCLogger
import ARCPurchasing
import Foundation

/// Factory for creating ``RevenueCatProvider`` instances behind the
/// ``PurchaseProviding`` protocol.
///
/// Backend-specific knobs (API key, internal StoreKit version) are
/// passed here so the shared ``PurchaseConfiguration`` can stay
/// agnostic.
///
/// ## Example
///
/// ```swift
/// import ARCPurchasing
/// import ARCPurchasingRevenueCat
///
/// let config = PurchaseConfiguration(entitlementIdentifiers: ["premium"])
/// try await ARCPurchaseManager.shared.configure(
///     with: config,
///     provider: RevenueCatProviderFactory.make(apiKey: "rc_xxx")
/// )
/// ```
public enum RevenueCatProviderFactory {
    /// Build a RevenueCat-backed ``PurchaseProviding``.
    ///
    /// - Parameters:
    ///   - apiKey: RevenueCat API key.
    ///   - storeKitVersion: Which StoreKit version RevenueCat should
    ///     use internally. Default: ``StoreKitVersion/storeKit2``.
    ///   - logger: Logger instance for purchase events.
    /// - Returns: A configured RevenueCat provider, type-erased to
    ///   ``PurchaseProviding``.
    public static func make(apiKey: String,
                            storeKitVersion: StoreKitVersion = .storeKit2,
                            logger: ARCLogger = .shared) -> any PurchaseProviding {
        RevenueCatProvider(apiKey: apiKey,
                           storeKitVersion: storeKitVersion,
                           logger: logger)
    }
}
