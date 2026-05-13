//
//  RevenueCatProvider.swift
//  ARCPurchasingRevenueCat
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCLogger
import ARCPurchasing
import Foundation
import RevenueCat

/// StoreKit version preference for the RevenueCat SDK.
///
/// Selects which underlying StoreKit version RevenueCat uses internally.
/// Lives in the RevenueCat module because it is meaningless to other
/// providers.
public enum StoreKitVersion: Sendable {
    /// Use StoreKit 1
    case storeKit1
    /// Use StoreKit 2 (recommended for iOS 15+)
    case storeKit2
}

/// RevenueCat-backed implementation of ``PurchaseProviding``.
///
/// All RevenueCat-specific configuration (API key, internal StoreKit
/// version) is supplied at construction time so the shared
/// ``PurchaseConfiguration`` can remain backend-agnostic.
///
/// - Note: Consumers should construct this through
///   ``RevenueCatProviderFactory/make(apiKey:storeKitVersion:logger:)``
///   and use it via ``ARCPurchaseManager`` rather than directly.
public actor RevenueCatProvider: PurchaseProviding {
    // MARK: - Private Properties

    private let apiKey: String
    private let storeKitVersion: StoreKitVersion
    private let logger: ARCLogger
    private var configuration: PurchaseConfiguration?

    // MARK: - Public Properties

    public var isConfigured: Bool {
        configuration != nil
    }

    // MARK: - Initialization

    /// Creates a RevenueCat provider.
    ///
    /// - Parameters:
    ///   - apiKey: RevenueCat API key (required).
    ///   - storeKitVersion: Which StoreKit version RevenueCat should use
    ///     internally. Default: ``StoreKitVersion/storeKit2``.
    ///   - logger: Logger instance for purchase events.
    public init(apiKey: String,
                storeKitVersion: StoreKitVersion = .storeKit2,
                logger: ARCLogger = .shared) {
        self.apiKey = apiKey
        self.storeKitVersion = storeKitVersion
        self.logger = logger
    }

    // MARK: - Configuration

    public func configure(with config: PurchaseConfiguration) async throws {
        logger.debug("[Purchase] Configuring RevenueCat provider")

        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PurchaseError.invalidConfiguration("RevenueCat API key must not be empty.")
        }

        // Configure RevenueCat SDK (must be called on main thread)
        await MainActor.run { [apiKey, storeKitVersion] in
            Purchases.logLevel = config.debugLoggingEnabled ? .debug : .error

            let rcStoreKitVersion: RevenueCat.StoreKitVersion =
                storeKitVersion == .storeKit1 ? .storeKit1 : .storeKit2

            Purchases.configure(with: Configuration.Builder(withAPIKey: apiKey)
                .with(storeKitVersion: rcStoreKitVersion)
                .build())
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

            let purchaseTransaction = result.transaction.map {
                PurchaseTransaction(id: $0.transactionIdentifier,
                                    productID: product.id,
                                    purchaseDate: $0.purchaseDate,
                                    price: product.price,
                                    currencyCode: product.currencyCode)
            } ?? PurchaseTransaction(id: UUID().uuidString,
                                     productID: product.id,
                                     purchaseDate: Date(),
                                     price: product.price,
                                     currencyCode: product.currencyCode)

            logger.info("[Purchase] Purchase successful: \(product.id)")
            return .success(purchaseTransaction)
        } catch {
            return try mapPurchaseError(error, productID: product.id)
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
            let mapper = configuration?.entitlementMapper
            return customerInfo.entitlements.active.values.map { $0.toEntitlement(mapper: mapper) }
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

    // MARK: - Purchase State Stream

    public nonisolated func purchaseStateDidChange() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                for await _ in Purchases.shared.customerInfoStream {
                    continuation.yield(())
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
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

    private func mapPurchaseError(_ error: Error, productID _: String) throws -> PurchaseResult {
        if let rcError = error as? RevenueCat.ErrorCode {
            switch rcError {
            case .purchaseCancelledError:
                return .cancelled
            case .paymentPendingError:
                return .pending
            case .purchaseNotAllowedError:
                return .requiresAction("Purchases not allowed on this device")
            case .networkError, .offlineConnectionError:
                logger.error("[Purchase] Network error: \(rcError)")
                throw PurchaseError.networkError(error.localizedDescription)
            case .storeProblemError, .unknownBackendError, .unexpectedBackendResponseError:
                logger.error("[Purchase] Store error: \(rcError)")
                throw PurchaseError.purchaseFailed(error.localizedDescription)
            default:
                logger.error("[Purchase] Purchase failed: \(rcError)")
                throw PurchaseError.purchaseFailed(rcError.localizedDescription)
            }
        }

        logger.error("[Purchase] Purchase failed with unknown error: \(error.localizedDescription)")
        throw PurchaseError.purchaseFailed(error.localizedDescription)
    }
}
