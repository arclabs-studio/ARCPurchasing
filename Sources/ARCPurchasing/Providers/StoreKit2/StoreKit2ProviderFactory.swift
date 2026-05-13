//
//  StoreKit2ProviderFactory.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import ARCLogger
import Foundation

/// Factory for creating ``StoreKit2Provider`` instances behind the
/// ``PurchaseProviding`` protocol.
///
/// Backend-specific knobs (product IDs, offerings map, app-account
/// token provider) are passed here so the shared
/// ``PurchaseConfiguration`` can stay agnostic.
///
/// ## Example
///
/// ```swift
/// import ARCPurchasing
///
/// let config = PurchaseConfiguration(entitlementIdentifiers: ["premium"])
/// try await ARCPurchaseManager.shared.configure(
///     with: config,
///     provider: StoreKit2ProviderFactory.make(
///         productIDs: ["com.app.monthly", "com.app.yearly"]
///     )
/// )
/// ```
public enum StoreKit2ProviderFactory {
    /// Build a StoreKit 2-backed ``PurchaseProviding``.
    ///
    /// - Parameters:
    ///   - productIDs: Product identifiers to load from the App Store.
    ///   - offerings: Optional offerings map. Keys are offering
    ///     identifiers; values are the product IDs in each offering.
    ///   - appAccountTokenProvider: Optional closure returning an
    ///     `appAccountToken` attached to every purchase.
    ///   - logger: Logger instance for purchase events.
    /// - Returns: A configured StoreKit 2 provider, type-erased to
    ///   ``PurchaseProviding``.
    public static func make(productIDs: Set<String>,
                            offerings: [String: Set<String>]? = nil,
                            appAccountTokenProvider: (@Sendable () -> UUID?)? = nil,
                            logger: ARCLogger = .shared) -> any PurchaseProviding {
        StoreKit2Provider(productIDs: productIDs,
                          offerings: offerings,
                          appAccountTokenProvider: appAccountTokenProvider,
                          logger: logger)
    }
}
