//
//  RevenueCatProvider.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCLogger
import Foundation
import RevenueCat

/// RevenueCat implementation of ``PurchaseProviding``.
///
/// This provider integrates with the RevenueCat SDK to handle all purchase
/// operations, including product fetching, purchasing, and entitlement management.
///
/// ## Usage
///
/// ```swift
/// let provider = RevenueCatProvider()
/// let config = PurchaseConfiguration(apiKey: "your_api_key")
/// try await provider.configure(with: config)
/// ```
///
/// - Note: This class is designed to be used through ``ARCPurchaseManager``
///   rather than directly.
public actor RevenueCatProvider: PurchaseProviding {
    // MARK: - Private Properties

    private let logger: ARCLogger
    private var configuration: PurchaseConfiguration?

    // MARK: - Public Properties

    public var isConfigured: Bool {
        configuration != nil
    }

    // MARK: - Initialization

    /// Creates a RevenueCat provider.
    ///
    /// - Parameter logger: Logger instance for purchase events.
    public init(logger: ARCLogger = .shared) {
        self.logger = logger
    }

    // MARK: - Configuration

    public func configure(with config: PurchaseConfiguration) async throws {
        logger.debug("[Purchase] Configuring RevenueCat provider")

        try config.validate()

        // Configure RevenueCat SDK (must be called on main thread)
        await MainActor.run {
            Purchases.logLevel = config.debugLoggingEnabled ? .debug : .error

            let rcStoreKitVersion: RevenueCat.StoreKitVersion = switch config.storeKitVersion {
            case .storeKit1: .storeKit1
            case .storeKit2: .storeKit2
            }

            Purchases.configure(
                with: Configuration.Builder(withAPIKey: config.apiKey)
                    .with(storeKitVersion: rcStoreKitVersion)
                    .build()
            )
        }

        // Identify user if provided
        if let userID = config.userID {
            try await identify(userID: userID)
        }

        configuration = config

        logger.info("[Purchase] RevenueCat configured successfully")
    }

    public func identify(userID: String?) async throws {
        if let userID {
            logger.debug("[Purchase] Identifying user: \(userID)")
            _ = try await Purchases.shared.logIn(userID)
        } else {
            logger.debug("[Purchase] Using anonymous user")
        }
    }

    public func logOut() async throws {
        logger.debug("[Purchase] Logging out user")
        _ = try await Purchases.shared.logOut()
    }

    // MARK: - ProductProviding

    public func fetchProducts(for identifiers: Set<String>) async throws -> [PurchaseProduct] {
        try ensureConfigured()

        logger.debug("[Purchase] Fetching products: \(identifiers)")

        let products = await Purchases.shared.products(Array(identifiers))

        guard !products.isEmpty else {
            throw PurchaseError.fetchProductsFailed("No products found for identifiers: \(identifiers)")
        }

        return products.map { $0.toPurchaseProduct() }
    }

    public func fetchOfferings() async throws -> [String: [PurchaseProduct]] {
        try ensureConfigured()

        logger.debug("[Purchase] Fetching offerings")

        let offerings = try await Purchases.shared.offerings()

        var result: [String: [PurchaseProduct]] = [:]

        for (key, offering) in offerings.all {
            result[key] = offering.availablePackages.map { $0.storeProduct.toPurchaseProduct() }
        }

        return result
    }

    // MARK: - TransactionProviding

    public func purchase(_ product: PurchaseProduct) async throws -> PurchaseResult {
        try ensureConfigured()

        logger.debug("[Purchase] Purchasing product: \(product.id)")

        // Extract RevenueCat product
        guard let rcProduct = product.underlyingProduct.value as? StoreProduct else {
            throw PurchaseError.productNotFound(product.id)
        }

        do {
            let result = try await Purchases.shared.purchase(product: rcProduct)

            if result.userCancelled {
                logger.info("[Purchase] Purchase cancelled by user")
                return .cancelled
            }

            let purchaseTransaction = result.transaction?.toPurchaseTransaction() ?? PurchaseTransaction(
                id: UUID().uuidString,
                productID: product.id,
                purchaseDate: Date()
            )

            logger.info("[Purchase] Purchase successful: \(product.id)")
            return .success(purchaseTransaction)
        } catch {
            return mapPurchaseError(error, productID: product.id)
        }
    }

    public func restorePurchases() async throws {
        try ensureConfigured()

        logger.debug("[Purchase] Restoring purchases")

        _ = try await Purchases.shared.restorePurchases()

        logger.info("[Purchase] Purchases restored successfully")
    }

    public func syncPurchases() async throws {
        try ensureConfigured()

        logger.debug("[Purchase] Syncing purchases")

        _ = try await Purchases.shared.syncPurchases()
    }

    // MARK: - EntitlementProviding

    public func hasEntitlement(_ identifier: String) async -> Bool {
        guard isConfigured else { return false }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[identifier]?.isActive ?? false
        } catch {
            logger.error("[Purchase] Failed to check entitlement: \(error.localizedDescription)")
            return false
        }
    }

    public func currentEntitlements() async -> [Entitlement] {
        guard isConfigured else { return [] }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements.active.values.map { $0.toEntitlement() }
        } catch {
            logger.error("[Purchase] Failed to get entitlements: \(error.localizedDescription)")
            return []
        }
    }

    public func subscriptionStatus() async -> SubscriptionStatus? {
        guard isConfigured else { return nil }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.toSubscriptionStatus()
        } catch {
            logger.error("[Purchase] Failed to get subscription status: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Private Helpers

extension RevenueCatProvider {
    private func ensureConfigured() throws {
        guard isConfigured else {
            throw PurchaseError.notConfigured
        }
    }

    private func mapPurchaseError(_ error: Error, productID _: String) -> PurchaseResult {
        if let rcError = error as? RevenueCat.ErrorCode {
            switch rcError {
            case .purchaseCancelledError:
                return .cancelled
            case .paymentPendingError:
                return .pending
            case .purchaseNotAllowedError:
                return .requiresAction("Purchases not allowed on this device")
            default:
                logger.error("[Purchase] Purchase failed: \(rcError)")
                return .unknown
            }
        }

        logger.error("[Purchase] Purchase failed with unknown error: \(error.localizedDescription)")
        return .unknown
    }
}
