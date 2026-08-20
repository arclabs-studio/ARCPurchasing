//
//  PurchaseProviding.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Main protocol that defines the complete purchase provider interface.
///
/// This protocol composes the sub-protocols for a unified API. Concrete
/// implementations live in their own modules and expose a factory that
/// returns `any PurchaseProviding`, so the abstraction layer never needs
/// to know which backend is in use.
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
/// // Backend-agnostic — construct via the factory of your chosen provider.
/// let provider: any PurchaseProviding = SomeProviderFactory.make(...)
/// try await provider.configure(with: config)
/// let products = try await provider.fetchProducts(for: ["premium_monthly"])
/// ```
public protocol PurchaseProviding: ProductProviding, TransactionProviding, EntitlementProviding, Sendable {
    /// Configure the provider with the given configuration.
    ///
    /// This must be called before any other operations.
    ///
    /// - Parameter config: The ``PurchaseConfiguration`` to use.
    /// - Throws: ``PurchaseError/invalidConfiguration(_:)`` when the
    ///           backend-specific configuration is missing or malformed,
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

    /// An async stream that emits whenever the customer's purchase state changes.
    ///
    /// Subscribe to this stream after configuration to receive real-time updates
    /// when subscriptions renew, expire, or billing issues are resolved.
    ///
    /// - Returns: An ``AsyncStream`` that emits `Void` on each state change.
    func purchaseStateDidChange() -> AsyncStream<Void>
}
