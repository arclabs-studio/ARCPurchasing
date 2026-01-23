//
//  ARCPurchaseManager.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCLogger
import Foundation

/// Main entry point for ARCPurchasing.
///
/// `ARCPurchaseManager` is the facade that coordinates all purchase operations,
/// delegating to the configured provider while managing state for SwiftUI integration.
///
/// ## Usage
///
/// ```swift
/// // Configure on app launch
/// let config = PurchaseConfiguration(
///     apiKey: "your_revenuecat_api_key",
///     entitlementIdentifiers: ["premium"]
/// )
/// try await ARCPurchaseManager.shared.configure(with: config)
///
/// // Check entitlements
/// let hasPremium = await ARCPurchaseManager.shared.hasEntitlement("premium")
///
/// // Purchase a product
/// let products = try await ARCPurchaseManager.shared.fetchProducts(for: ["premium_monthly"])
/// if let product = products.first {
///     let result = try await ARCPurchaseManager.shared.purchase(product)
/// }
/// ```
///
/// ## SwiftUI Integration
///
/// ```swift
/// struct SubscriptionView: View {
///     @State private var purchaseManager = ARCPurchaseManager.shared
///
///     var body: some View {
///         if purchaseManager.subscriptionStatus?.isSubscribed == true {
///             Text("Subscribed!")
///         } else {
///             Button("Subscribe") { /* ... */ }
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class ARCPurchaseManager {
    // MARK: - Singleton

    /// Shared instance of the purchase manager.
    public static let shared = ARCPurchaseManager()

    // MARK: - Observable State

    /// Whether the manager has been configured.
    public private(set) var isConfigured = false

    /// Current active entitlements for the user.
    public private(set) var currentEntitlements: [Entitlement] = []

    /// Current subscription status for the user.
    public private(set) var subscriptionStatus: SubscriptionStatus?

    /// Whether a purchase operation is in progress.
    public private(set) var isPurchasing = false

    /// Whether a restore operation is in progress.
    public private(set) var isRestoring = false

    // MARK: - Private Properties

    private var provider: (any PurchaseProviding)?
    private var analytics: (any PurchaseAnalytics)?
    private let logger: ARCLogger

    // MARK: - Initialization

    /// Creates a purchase manager.
    ///
    /// - Parameter logger: Logger instance for purchase events.
    public init(logger: ARCLogger = .shared) {
        self.logger = logger
    }

    // MARK: - Configuration

    /// Configure the purchase manager with RevenueCat.
    ///
    /// This must be called before any other operations, typically during app launch.
    ///
    /// - Parameters:
    ///   - config: Purchase configuration with API key and settings.
    ///   - analytics: Optional custom analytics handler.
    /// - Throws: ``PurchaseError`` if configuration fails.
    public func configure(
        with config: PurchaseConfiguration,
        analytics: (any PurchaseAnalytics)? = nil
    ) async throws {
        logger.info("[Purchase] Configuring ARCPurchaseManager")

        let provider = RevenueCatProvider(logger: logger)
        try await provider.configure(with: config)

        self.provider = provider
        self.analytics = analytics ?? DefaultPurchaseAnalytics(logger: logger)
        isConfigured = true

        // Initial state sync
        await refreshState()

        logger.info("[Purchase] ARCPurchaseManager configured successfully")
    }

    // MARK: - Products

    /// Fetch products by identifiers.
    ///
    /// - Parameter identifiers: Set of product identifiers to fetch.
    /// - Returns: Array of ``PurchaseProduct`` matching the identifiers.
    /// - Throws: ``PurchaseError`` if fetching fails.
    public func fetchProducts(for identifiers: Set<String>) async throws -> [PurchaseProduct] {
        guard let provider else {
            throw PurchaseError.notConfigured
        }

        return try await provider.fetchProducts(for: identifiers)
    }

    /// Fetch all offerings.
    ///
    /// - Returns: Dictionary mapping offering identifiers to products.
    /// - Throws: ``PurchaseError`` if fetching fails.
    public func fetchOfferings() async throws -> [String: [PurchaseProduct]] {
        guard let provider else {
            throw PurchaseError.notConfigured
        }

        return try await provider.fetchOfferings()
    }

    // MARK: - Purchase

    /// Purchase a product.
    ///
    /// - Parameter product: The product to purchase.
    /// - Returns: ``PurchaseResult`` indicating the outcome.
    /// - Throws: ``PurchaseError`` if the operation fails.
    public func purchase(_ product: PurchaseProduct) async throws -> PurchaseResult {
        guard let provider else {
            throw PurchaseError.notConfigured
        }

        isPurchasing = true
        defer { isPurchasing = false }

        await analytics?.track(.purchaseStarted(productID: product.id))

        let result = try await provider.purchase(product)

        switch result {
        case let .success(transaction):
            await analytics?.track(.purchaseCompleted(
                productID: product.id,
                price: transaction.price ?? product.price,
                currency: transaction.currencyCode ?? product.currencyCode,
                transactionID: transaction.id
            ))
            await refreshState()

        case .cancelled:
            await analytics?.track(.purchaseCancelled(productID: product.id))

        case .pending:
            await analytics?.track(.purchasePending(productID: product.id))

        case let .requiresAction(action):
            await analytics?.track(.purchaseFailed(productID: product.id, error: action))

        case .unknown:
            await analytics?.track(.purchaseFailed(productID: product.id, error: "Unknown error"))
        }

        return result
    }

    /// Restore previous purchases.
    ///
    /// - Throws: ``PurchaseError`` if restoration fails.
    public func restorePurchases() async throws {
        guard let provider else {
            throw PurchaseError.notConfigured
        }

        isRestoring = true
        defer { isRestoring = false }

        await analytics?.track(.restorePurchasesStarted)

        do {
            try await provider.restorePurchases()
            await refreshState()
            await analytics?.track(.restorePurchasesCompleted)
        } catch {
            await analytics?.track(.restorePurchasesFailed(error: error.localizedDescription))
            throw error
        }
    }

    // MARK: - Entitlements

    /// Check if user has a specific entitlement.
    ///
    /// - Parameter identifier: The entitlement identifier to check.
    /// - Returns: `true` if user has the active entitlement.
    public func hasEntitlement(_ identifier: String) async -> Bool {
        guard let provider else { return false }
        return await provider.hasEntitlement(identifier)
    }

    /// Refresh entitlements and subscription status.
    ///
    /// Call this to manually refresh state, for example after
    /// returning from background.
    public func refreshState() async {
        guard let provider else { return }

        currentEntitlements = await provider.currentEntitlements()
        subscriptionStatus = await provider.subscriptionStatus()
    }

    // MARK: - User Management

    /// Identify the current user.
    ///
    /// - Parameter userID: User identifier to associate with purchases.
    /// - Throws: ``PurchaseError`` if identification fails.
    public func identify(userID: String) async throws {
        guard let provider else {
            throw PurchaseError.notConfigured
        }

        try await provider.identify(userID: userID)
        await refreshState()
    }

    /// Log out the current user.
    ///
    /// - Throws: ``PurchaseError`` if logout fails.
    public func logOut() async throws {
        guard let provider else {
            throw PurchaseError.notConfigured
        }

        try await provider.logOut()
        await refreshState()
    }
}

// MARK: - Convenience Properties

extension ARCPurchaseManager {
    /// Whether the user has any active subscription.
    public var isSubscribed: Bool {
        subscriptionStatus?.isSubscribed ?? false
    }

    /// Whether there are any active entitlements.
    public var hasActiveEntitlements: Bool {
        currentEntitlements.contains(where: \.isActive)
    }
}
