//
//  ProductProviding.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation

/// Protocol for fetching product information from a purchase provider.
///
/// Abstracts product loading so the rest of the package never sees a
/// provider's native product type.
public protocol ProductProviding: Sendable {
    /// Fetch available products by their identifiers.
    ///
    /// - Parameter identifiers: Set of product identifiers to fetch.
    /// - Returns: Array of ``PurchaseProduct`` matching the requested identifiers.
    /// - Throws: ``PurchaseError`` if fetching fails.
    func fetchProducts(for identifiers: Set<String>) async throws -> [PurchaseProduct]

    /// Fetch current offerings — named groups of products.
    ///
    /// Offerings are a provider-defined concept. Backends that organise
    /// products server-side surface those groupings here; backends that
    /// expose a flat product list typically return a single `"default"`
    /// key. Consumers should not rely on a specific number of keys
    /// being present.
    ///
    /// - Returns: Dictionary mapping offering identifiers to their products.
    /// - Throws: ``PurchaseError`` if fetching fails.
    func fetchOfferings() async throws -> [String: [PurchaseProduct]]
}
