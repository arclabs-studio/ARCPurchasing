//
//  PurchaseConfiguration.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// StoreKit version preference for RevenueCat.
public enum StoreKitVersion: Sendable {
    /// Use StoreKit 1
    case storeKit1
    /// Use StoreKit 2 (recommended for iOS 15+)
    case storeKit2
}

/// Configuration for the purchase provider.
///
/// `PurchaseConfiguration` contains all settings needed to initialize
/// a purchase provider, including API credentials and behavior options.
///
/// ## Example
///
/// ```swift
/// let config = PurchaseConfiguration(
///     apiKey: "your_revenuecat_api_key",
///     entitlementIdentifiers: ["premium", "pro"]
/// )
/// try await ARCPurchaseManager.shared.configure(with: config)
/// ```
public struct PurchaseConfiguration: Sendable {
    // MARK: - Public Properties

    /// API key for the provider (e.g., RevenueCat API key).
    public let apiKey: String

    /// Optional user ID to identify on configuration.
    public let userID: String?

    /// Whether to enable debug logging.
    public let debugLoggingEnabled: Bool

    /// StoreKit version preference (RevenueCat specific).
    public let storeKitVersion: StoreKitVersion

    /// Entitlement identifiers to track.
    public let entitlementIdentifiers: Set<String>

    // MARK: - Initialization

    /// Creates a purchase configuration.
    ///
    /// - Parameters:
    ///   - apiKey: API key for the provider.
    ///   - userID: Optional user ID for identification.
    ///   - debugLoggingEnabled: Enable debug logging (default: `false`).
    ///   - storeKitVersion: StoreKit version to use (default: `.storeKit2`).
    ///   - entitlementIdentifiers: Set of entitlement IDs to track.
    public init(
        apiKey: String,
        userID: String? = nil,
        debugLoggingEnabled: Bool = false,
        storeKitVersion: StoreKitVersion = .storeKit2,
        entitlementIdentifiers: Set<String> = []
    ) {
        self.apiKey = apiKey
        self.userID = userID
        self.debugLoggingEnabled = debugLoggingEnabled
        self.storeKitVersion = storeKitVersion
        self.entitlementIdentifiers = entitlementIdentifiers
    }
}

// MARK: - Validation

extension PurchaseConfiguration {
    /// Validates the configuration.
    ///
    /// - Throws: ``PurchaseError/invalidAPIKey`` if API key is empty.
    public func validate() throws {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PurchaseError.invalidAPIKey
        }
    }
}
