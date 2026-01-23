//
//  PurchaseError.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Domain errors for purchase operations.
///
/// `PurchaseError` provides typed errors for all purchase-related failures,
/// enabling proper error handling and user-friendly error messages.
public enum PurchaseError: Error, Sendable, Equatable {
    // MARK: - Configuration Errors

    /// Provider not configured. Call `configure()` first.
    case notConfigured

    /// Invalid API key provided.
    case invalidAPIKey

    // MARK: - Product Errors

    /// Product not found with the given identifier.
    case productNotFound(String)

    /// Failed to fetch products.
    case fetchProductsFailed(String)

    // MARK: - Purchase Errors

    /// Purchase operation failed.
    case purchaseFailed(String)

    /// User cancelled the purchase.
    case userCancelled

    /// Payment is pending approval.
    case paymentPending

    /// Device not allowed to make purchases.
    case purchaseNotAllowed

    // MARK: - Entitlement Errors

    /// Failed to verify entitlements.
    case entitlementVerificationFailed(String)

    // MARK: - Network Errors

    /// Network error occurred.
    case networkError(String)

    /// Request timed out.
    case timeout

    // MARK: - Unknown Errors

    /// Unknown error occurred.
    case unknown(String)
}

// MARK: - LocalizedError

extension PurchaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            String(localized: "Purchase provider is not configured. Call configure() first.")
        case .invalidAPIKey:
            String(localized: "Invalid API key provided.")
        case let .productNotFound(id):
            String(localized: "Product not found: \(id)")
        case let .fetchProductsFailed(reason):
            String(localized: "Failed to fetch products: \(reason)")
        case let .purchaseFailed(reason):
            String(localized: "Purchase failed: \(reason)")
        case .userCancelled:
            String(localized: "Purchase was cancelled.")
        case .paymentPending:
            String(localized: "Payment is pending approval.")
        case .purchaseNotAllowed:
            String(localized: "Purchases are not allowed on this device.")
        case let .entitlementVerificationFailed(reason):
            String(localized: "Entitlement verification failed: \(reason)")
        case let .networkError(reason):
            String(localized: "Network error: \(reason)")
        case .timeout:
            String(localized: "Request timed out.")
        case let .unknown(reason):
            String(localized: "An error occurred: \(reason)")
        }
    }
}

// MARK: - Recovery Suggestions

extension PurchaseError {
    /// Suggests whether the user can retry the operation.
    public var isRetryable: Bool {
        switch self {
        case .networkError, .timeout:
            true
        case .notConfigured, .invalidAPIKey, .productNotFound, .userCancelled, .purchaseNotAllowed:
            false
        case .fetchProductsFailed, .purchaseFailed, .entitlementVerificationFailed, .paymentPending, .unknown:
            true
        }
    }

    /// User-friendly recovery suggestion.
    public var recoverySuggestion: String? {
        switch self {
        case .notConfigured:
            String(localized: "Please restart the app and try again.")
        case .invalidAPIKey:
            String(localized: "Please contact support.")
        case .networkError, .timeout:
            String(localized: "Please check your internet connection and try again.")
        case .purchaseNotAllowed:
            String(localized: "Please check your device settings to enable purchases.")
        case .paymentPending:
            String(localized: "Your purchase is awaiting approval. You'll be notified when it's complete.")
        default:
            nil
        }
    }
}
