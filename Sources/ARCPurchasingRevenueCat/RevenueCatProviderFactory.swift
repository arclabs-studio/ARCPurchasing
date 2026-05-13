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
/// Use this from your app's configuration entry point:
///
/// ```swift
/// import ARCPurchasing
/// import ARCPurchasingRevenueCat
///
/// try await ARCPurchaseManager.shared.configure(
///     with: PurchaseConfiguration(apiKey: "rc_xxx"),
///     provider: RevenueCatProviderFactory.make()
/// )
/// ```
public enum RevenueCatProviderFactory {
    /// Build a RevenueCat-backed ``PurchaseProviding``.
    ///
    /// - Parameter logger: Logger instance to use for purchase events.
    /// - Returns: A configured RevenueCat provider, type-erased to ``PurchaseProviding``.
    public static func make(logger: ARCLogger = .shared) -> any PurchaseProviding {
        RevenueCatProvider(logger: logger)
    }
}

// MARK: - Backward-compat convenience

public extension ARCPurchaseManager {
    /// Configure the purchase manager using the RevenueCat provider.
    ///
    /// This convenience wraps ``ARCPurchaseManager/configure(with:provider:analytics:)``
    /// with ``RevenueCatProviderFactory/make(logger:)``, preserving the
    /// API shape from earlier ARCPurchasing versions.
    ///
    /// Available only when `ARCPurchasingRevenueCat` is imported.
    ///
    /// - Parameters:
    ///   - config: Purchase configuration with API key and settings.
    ///   - analytics: Optional custom analytics handler.
    /// - Throws: ``PurchaseError`` if configuration fails.
    func configure(with config: PurchaseConfiguration,
                   analytics: (any PurchaseAnalytics)? = nil) async throws {
        try await configure(with: config,
                            provider: RevenueCatProviderFactory.make(),
                            analytics: analytics)
    }
}
