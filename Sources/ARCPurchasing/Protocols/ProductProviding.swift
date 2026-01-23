//
//  ProductProviding.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Protocol for fetching product information from a purchase provider.
///
/// This protocol abstracts the product fetching capabilities, allowing different
/// implementations (RevenueCat, StoreKit 2 native, etc.) to be used interchangeably.
public protocol ProductProviding: Sendable {
    /// Fetch available products by their identifiers.
    ///
    /// - Parameter identifiers: Set of product identifiers to fetch.
    /// - Returns: Array of ``PurchaseProduct`` matching the requested identifiers.
    /// - Throws: ``PurchaseError`` if fetching fails.
    func fetchProducts(for identifiers: Set<String>) async throws -> [PurchaseProduct]

    /// Fetch current offerings (provider-organized product groups).
    ///
    /// Offerings are a provider-specific concept (common in RevenueCat) that groups
    /// products by use case. For providers without this concept, return products
    /// grouped by a default key.
    ///
    /// - Returns: Dictionary mapping offering identifiers to their products.
    /// - Throws: ``PurchaseError`` if fetching fails.
    func fetchOfferings() async throws -> [String: [PurchaseProduct]]
}
