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
/// Use this from your app's configuration entry point:
///
/// ```swift
/// import ARCPurchasing
///
/// try await ARCPurchaseManager.shared.configure(
///     with: PurchaseConfiguration(productIDs: ["com.app.monthly"]),
///     provider: StoreKit2ProviderFactory.make()
/// )
/// ```
public enum StoreKit2ProviderFactory {
    /// Build a StoreKit 2-backed ``PurchaseProviding``.
    ///
    /// - Parameter logger: Logger instance to use for purchase events.
    /// - Returns: A configured StoreKit 2 provider, type-erased to ``PurchaseProviding``.
    public static func make(logger: ARCLogger = .shared) -> any PurchaseProviding {
        StoreKit2Provider(logger: logger)
    }
}
