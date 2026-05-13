//
//  StoreKit2Provider.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import ARCLogger
import CryptoKit
import Foundation
import StoreKit

/// Native StoreKit 2 implementation of ``PurchaseProviding``.
///
/// Backed entirely by Apple's first-party StoreKit 2 APIs (`Product`,
/// `Transaction`, `AppStore`), this provider removes the third-party
/// RevenueCat dependency for apps that have migrated to native in-app
/// purchase handling.
///
/// ## Usage
///
/// ```swift
/// import ARCPurchasing
///
/// let config = PurchaseConfiguration(
///     productIDs: ["com.app.monthly", "com.app.yearly"],
///     entitlementIdentifiers: ["premium"]
/// )
/// try await ARCPurchaseManager.shared.configure(
///     with: config,
///     provider: StoreKit2ProviderFactory.make()
/// )
/// ```
///
/// - Note: Consumers should construct this through
///   ``StoreKit2ProviderFactory/make(logger:)`` and use it via
///   ``ARCPurchaseManager`` rather than directly.
public actor StoreKit2Provider: PurchaseProviding {
    // MARK: - Private Properties

    private let logger: ARCLogger
    private var configuration: PurchaseConfiguration?
    private var appAccountToken: UUID?
    private var transactionListener: Task<Void, Never>?
    private var stateContinuation: AsyncStream<Void>.Continuation?

    // MARK: - Public Properties

    public var isConfigured: Bool {
        configuration != nil
    }

    // MARK: - Initialization

    /// Creates a StoreKit 2 provider.
    ///
    /// - Parameter logger: Logger instance for purchase events.
    public init(logger: ARCLogger = .shared) {
        self.logger = logger
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Configuration

    public func configure(with config: PurchaseConfiguration) async throws {
        logger.debug("[Purchase] Configuring StoreKit 2 provider")

        try config.validate()

        guard config.storeKit2 != nil else {
            throw PurchaseError.notConfigured
        }

        configuration = config
        appAccountToken = config.storeKit2?.appAccountTokenProvider?()

        startTransactionListener()

        if let userID = config.userID {
            try await identify(userID: userID)
        }

        logger.info("[Purchase] StoreKit 2 provider configured successfully")
    }

    public func identify(userID: String?) async throws {
        guard let userID, !userID.isEmpty else {
            appAccountToken = nil
            stateContinuation?.yield(())
            return
        }

        // Derive a deterministic UUID from the userID so the App Store can
        // correlate purchases with the same user across sessions/devices.
        appAccountToken = StoreKit2Provider.deterministicUUID(from: userID)
        logger.debug("[Purchase] Identified user, derived appAccountToken")
        stateContinuation?.yield(())
    }

    public func logOut() async throws {
        appAccountToken = nil
        // Re-arm the listener with no user binding so future renewals/
        // family-sharing grants still flow through.
        startTransactionListener()
        stateContinuation?.yield(())
    }

    // MARK: - ProductProviding

    public func fetchProducts(for identifiers: Set<String>) async throws -> [PurchaseProduct] {
        try ensureConfigured()

        logger.debug("[Purchase] Fetching products: \(identifiers)")

        let products: [Product]
        do {
            products = try await Product.products(for: identifiers)
        } catch {
            throw PurchaseError.fetchProductsFailed(error.localizedDescription)
        }

        guard !products.isEmpty else {
            throw PurchaseError.fetchProductsFailed("No products found for identifiers: \(identifiers)")
        }

        return products.map { $0.toPurchaseProduct() }
    }

    public func fetchOfferings() async throws -> [String: [PurchaseProduct]] {
        try ensureConfigured()

        guard let sk2 = configuration?.storeKit2 else {
            throw PurchaseError.notConfigured
        }

        logger.debug("[Purchase] Fetching offerings")

        if let offeringsMap = sk2.offerings, !offeringsMap.isEmpty {
            var result: [String: [PurchaseProduct]] = [:]
            for (key, productIDs) in offeringsMap {
                result[key] = try await fetchProducts(for: productIDs)
            }
            return result
        }

        // No offerings map provided — expose all configured products under "default".
        let products = try await fetchProducts(for: sk2.productIDs)
        return ["default": products]
    }

    // MARK: - TransactionProviding

    public func purchase(_ product: PurchaseProduct) async throws -> PurchaseResult {
        try ensureConfigured()

        logger.debug("[Purchase] Purchasing product: \(product.id)")

        guard let nativeProduct = product.underlyingProduct.value as? Product else {
            throw PurchaseError.productNotFound(product.id)
        }

        do {
            let result = try await nativeProduct.purchase(options: purchaseOptions())
            return try await handlePurchaseResult(result, for: product)
        } catch let error as PurchaseError {
            throw error
        } catch StoreKitError.userCancelled {
            return .cancelled
        } catch {
            logger.error("[Purchase] Purchase failed: \(error.localizedDescription)")
            throw PurchaseError.purchaseFailed(error.localizedDescription)
        }
    }

    private func purchaseOptions() -> Set<Product.PurchaseOption> {
        var options: Set<Product.PurchaseOption> = []
        if let token = appAccountToken {
            options.insert(.appAccountToken(token))
        }
        return options
    }

    private func handlePurchaseResult(_ result: Product.PurchaseResult,
                                      for product: PurchaseProduct) async throws -> PurchaseResult {
        switch result {
        case let .success(verification):
            return try await handleVerifiedPurchase(verification, for: product)
        case .userCancelled:
            logger.info("[Purchase] Purchase cancelled by user")
            return .cancelled
        case .pending:
            logger.info("[Purchase] Purchase pending approval")
            return .pending
        @unknown default:
            logger.error("[Purchase] Unknown purchase result")
            return .unknown
        }
    }

    private func handleVerifiedPurchase(_ verification: VerificationResult<Transaction>,
                                        for product: PurchaseProduct) async throws -> PurchaseResult {
        let jws = verification.jwsRepresentation
        switch verification {
        case let .verified(transaction):
            await transaction.finish()
            stateContinuation?.yield(())
            logger.info("[Purchase] Purchase successful: \(product.id)")
            return .success(makePurchaseTransaction(from: transaction, product: product, jws: jws))
        case let .unverified(_, error):
            logger.error("[Purchase] Unverified transaction: \(error.localizedDescription)")
            throw PurchaseError.entitlementVerificationFailed(error.localizedDescription)
        }
    }

    private func makePurchaseTransaction(from transaction: Transaction,
                                         product: PurchaseProduct,
                                         jws: String) -> PurchaseTransaction {
        let originalID: String? = transaction.id == transaction.originalID
            ? nil
            : String(transaction.originalID)
        return PurchaseTransaction(id: String(transaction.id),
                                   productID: transaction.productID,
                                   originalTransactionID: originalID,
                                   purchaseDate: transaction.purchaseDate,
                                   expiresDate: transaction.expirationDate,
                                   isRestored: false,
                                   price: product.price,
                                   currencyCode: product.currencyCode,
                                   jwsRepresentation: jws)
    }

    public func restorePurchases() async throws {
        try ensureConfigured()

        logger.debug("[Purchase] Restoring purchases via AppStore.sync()")

        do {
            try await AppStore.sync()
            stateContinuation?.yield(())
            logger.info("[Purchase] Purchases restored successfully")
        } catch {
            logger.error("[Purchase] Restore failed: \(error.localizedDescription)")
            throw PurchaseError.purchaseFailed(error.localizedDescription)
        }
    }

    public func syncPurchases() async throws {
        try ensureConfigured()

        // Silent refresh — StoreKit 2 auto-syncs via `Transaction.updates`.
        // We just nudge state observers to recompute current entitlements.
        // We intentionally do NOT call `AppStore.sync()` here because it
        // prompts the user for their App Store password.
        logger.debug("[Purchase] Silent sync — yielding state change")
        stateContinuation?.yield(())
    }

    // MARK: - EntitlementProviding

    public func hasEntitlement(_ identifier: String) async -> Bool {
        guard isConfigured else { return false }
        let entitlements = await currentEntitlements()
        return entitlements.contains { $0.id == identifier && $0.isActive }
    }

    public func currentEntitlements() async -> [Entitlement] {
        guard isConfigured else { return [] }

        let mapper = configuration?.storeKit2?.entitlementMapper
        var results: [Entitlement] = []

        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            guard transaction.revocationDate == nil else { continue }

            if let expiration = transaction.expirationDate, expiration <= .now {
                continue
            }

            let entitlementID = mapper?(transaction.productID) ?? transaction.productID
            let willRenew = await willRenew(for: transaction.productID)
            let periodType = StoreKit2Provider.periodType(for: transaction)

            let entitlement = Entitlement(id: entitlementID,
                                          isActive: true,
                                          productIdentifier: transaction.productID,
                                          expiresDate: transaction.expirationDate,
                                          willRenew: willRenew,
                                          periodType: periodType)
            results.append(entitlement)
        }

        return results
    }

    public func subscriptionStatus() async -> SubscriptionStatus? {
        guard isConfigured else { return nil }

        var activeTransaction: Transaction?
        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            guard transaction.productType == .autoRenewable else { continue }
            guard transaction.revocationDate == nil else { continue }
            activeTransaction = transaction
            break
        }

        guard let transaction = activeTransaction else {
            return SubscriptionStatus(isSubscribed: false,
                                      managementURL: StoreKit2Provider.managementURL)
        }

        let (renewalState, willAutoRenew) = await renewalDetails(for: transaction.productID)

        let isInBillingRetry = renewalState == .inBillingRetryPeriod
        let isInGracePeriod = renewalState == .inGracePeriod
        let isSubscribed = renewalState == .subscribed || isInGracePeriod || isInBillingRetry

        return SubscriptionStatus(isSubscribed: isSubscribed,
                                  activeProductID: transaction.productID,
                                  expiresDate: transaction.expirationDate,
                                  willRenew: willAutoRenew,
                                  isInBillingRetry: isInBillingRetry,
                                  isInGracePeriod: isInGracePeriod,
                                  managementURL: StoreKit2Provider.managementURL)
    }

    // MARK: - Purchase State Stream

    public nonisolated func purchaseStateDidChange() -> AsyncStream<Void> {
        AsyncStream { continuation in
            Task { await self.register(continuation: continuation) }
        }
    }
}

// MARK: - Private Helpers

private extension StoreKit2Provider {
    func ensureConfigured() throws {
        guard isConfigured else {
            throw PurchaseError.notConfigured
        }
    }

    func register(continuation: AsyncStream<Void>.Continuation) {
        // Single-subscriber model: replace any previous continuation.
        stateContinuation?.finish()
        stateContinuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.clearContinuation() }
        }
    }

    func clearContinuation() {
        stateContinuation = nil
    }

    func startTransactionListener() {
        transactionListener?.cancel()
        transactionListener = Task { [weak self] in
            for await update in Transaction.updates {
                guard !Task.isCancelled else { break }
                await self?.handle(update: update)
            }
        }
    }

    func handle(update: VerificationResult<Transaction>) async {
        switch update {
        case let .verified(transaction):
            logger.debug("[Purchase] Listener received verified transaction: \(transaction.productID)")
            await transaction.finish()
            stateContinuation?.yield(())

        case let .unverified(transaction, error):
            let reason = error.localizedDescription
            logger.error("[Purchase] Unverified transaction \(transaction.productID): \(reason)")
            // Finish so it doesn't loop on next launch; do not grant entitlement.
            await transaction.finish()
        }
    }

    func willRenew(for productID: String) async -> Bool {
        guard let products = try? await Product.products(for: [productID]),
              let product = products.first,
              let status = try? await product.subscription?.status.first
        else {
            return false
        }
        guard case let .verified(renewalInfo) = status.renewalInfo else {
            return false
        }
        return renewalInfo.willAutoRenew
    }

    func renewalDetails(for productID: String) async
    -> (state: Product.SubscriptionInfo.RenewalState?, willAutoRenew: Bool) {
        guard let products = try? await Product.products(for: [productID]),
              let product = products.first,
              let status = try? await product.subscription?.status.first
        else {
            return (nil, false)
        }
        let willAutoRenew: Bool = if case let .verified(renewalInfo) = status.renewalInfo {
            renewalInfo.willAutoRenew
        } else {
            false
        }
        return (status.state, willAutoRenew)
    }
}

// MARK: - Internal Static Helpers (testable)

extension StoreKit2Provider {
    static func periodType(for transaction: Transaction) -> EntitlementPeriodType {
        // NOTE: StoreKit 2's `Transaction.offerType` does not surface
        // the payment mode on iOS 17.0. The trial/intro distinction
        // requires a separate `Product.SubscriptionInfo` fetch which
        // we skip for v1 — introductory offers are reported as `.intro`
        // regardless of whether they are free trials. Use
        // ``Entitlement/periodType`` for coarse-grained classification only.
        guard let offerType = transaction.offerType else {
            return .normal
        }
        switch offerType {
        case .introductory:
            return .intro
        case .promotional:
            return .promotional
        default:
            return .normal
        }
    }

    static func deterministicUUID(from input: String) -> UUID {
        let digest = SHA256.hash(data: Data(input.utf8))
        var bytes = Array(digest.prefix(16))
        // Set version (4) and variant bits per RFC 4122 so consumers see a
        // valid v4-shaped UUID; the entropy itself is derived deterministically.
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        let uuid = uuid_t(bytes[0], bytes[1], bytes[2], bytes[3],
                          bytes[4], bytes[5], bytes[6], bytes[7],
                          bytes[8], bytes[9], bytes[10], bytes[11],
                          bytes[12], bytes[13], bytes[14], bytes[15])
        return UUID(uuid: uuid)
    }

    static var managementURL: URL? {
        URL(string: "https://apps.apple.com/account/subscriptions")
    }
}
