//
//  PurchaseProviding.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Main protocol that defines the complete purchase provider interface.
///
/// This protocol composes all sub-protocols for a unified API, representing
/// a complete purchase provider implementation. Implementations include
/// ``RevenueCatProvider`` and future native StoreKit 2 providers.
///
/// ## Conformance Requirements
///
/// Types conforming to `PurchaseProviding` must:
/// - Be `Sendable` for safe use across concurrency domains
/// - Implement all methods from ``ProductProviding``, ``TransactionProviding``,
///   and ``EntitlementProviding``
///
/// ## Example
///
/// ```swift
/// let provider: any PurchaseProviding = RevenueCatProvider()
/// try await provider.configure(with: config)
/// let products = try await provider.fetchProducts(for: ["premium_monthly"])
/// ```
public protocol PurchaseProviding: ProductProviding, TransactionProviding, EntitlementProviding, Sendable {
    /// Configure the provider with the given configuration.
    ///
    /// This must be called before any other operations.
    ///
    /// - Parameter config: The ``PurchaseConfiguration`` to use.
    /// - Throws: ``PurchaseError/invalidAPIKey`` if the API key is invalid,
    ///           or other errors during configuration.
    func configure(with config: PurchaseConfiguration) async throws

    /// Identify the current user.
    ///
    /// - Parameter userID: Optional user identifier. If `nil`, uses anonymous ID.
    /// - Throws: ``PurchaseError`` if identification fails.
    func identify(userID: String?) async throws

    /// Log out the current user.
    ///
    /// This clears the current user session and reverts to anonymous mode.
    ///
    /// - Throws: ``PurchaseError`` if logout fails.
    func logOut() async throws

    /// Whether the provider has been configured.
    ///
    /// Operations will fail with ``PurchaseError/notConfigured`` if this is `false`.
    var isConfigured: Bool { get async }
}
