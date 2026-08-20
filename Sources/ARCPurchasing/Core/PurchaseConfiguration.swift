//
//  PurchaseConfiguration.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Provider-agnostic configuration shared by every ``PurchaseProviding``.
///
/// This type intentionally contains only knobs that apply to every
/// backend — user identity, entitlement bookkeeping, logging, and the
/// optional entitlement mapper. Backend-specific settings (API keys,
/// product identifiers, App Store offerings, etc.) live on the
/// provider factory of that backend so the abstraction layer stays
/// clean.
///
/// ## Example
///
/// ```swift
/// let config = PurchaseConfiguration(
///     userID: currentUserID,
///     entitlementIdentifiers: ["premium"],
///     entitlementMapper: { _ in "premium" }
/// )
/// try await ARCPurchaseManager.shared.configure(
///     with: config,
///     provider: someProviderFactory.make(...)
/// )
/// ```
public struct PurchaseConfiguration: Sendable {
    // MARK: - Public Properties

    /// Optional user identifier propagated to the provider.
    public let userID: String?

    /// Whether to enable verbose debug logging.
    public let debugLoggingEnabled: Bool

    /// Entitlement identifiers the consuming app cares about.
    public let entitlementIdentifiers: Set<String>

    /// Maps a product identifier to a logical entitlement identifier.
    ///
    /// Default behaviour (when `nil`) keys ``Entitlement/id`` by the
    /// underlying product ID. Supply a closure to group multiple
    /// product IDs (e.g., monthly + yearly subscriptions) under a
    /// single logical entitlement like `"premium"`.
    public let entitlementMapper: (@Sendable (_ productID: String) -> String)?

    // MARK: - Initialization

    /// Creates a purchase configuration.
    ///
    /// - Parameters:
    ///   - userID: Optional user identifier propagated to the provider.
    ///   - debugLoggingEnabled: Enable verbose debug logging.
    ///   - entitlementIdentifiers: Entitlement identifiers to track.
    ///   - entitlementMapper: Optional closure that maps a product ID
    ///     to a logical entitlement identifier.
    public init(userID: String? = nil,
                debugLoggingEnabled: Bool = false,
                entitlementIdentifiers: Set<String> = [],
                entitlementMapper: (@Sendable (String) -> String)? = nil) {
        self.userID = userID
        self.debugLoggingEnabled = debugLoggingEnabled
        self.entitlementIdentifiers = entitlementIdentifiers
        self.entitlementMapper = entitlementMapper
    }
}
