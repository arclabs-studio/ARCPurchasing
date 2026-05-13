//
//  PurchaseConfigurationTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

struct PurchaseConfigurationTests {
    // MARK: - Initialization Tests

    @Test("Initialization sets all properties correctly") func initialization_setsAllProperties() {
        let config = PurchaseConfiguration(userID: "user_123",
                                           debugLoggingEnabled: true,
                                           entitlementIdentifiers: ["premium", "pro"])

        #expect(config.userID == "user_123")
        #expect(config.debugLoggingEnabled == true)
        #expect(config.entitlementIdentifiers == ["premium", "pro"])
        #expect(config.entitlementMapper == nil)
    }

    @Test("Default values are correct") func initialization_defaultValues() {
        let config = PurchaseConfiguration()

        #expect(config.userID == nil)
        #expect(config.debugLoggingEnabled == false)
        #expect(config.entitlementIdentifiers.isEmpty)
        #expect(config.entitlementMapper == nil)
    }

    @Test("Entitlement mapper is preserved") func initialization_entitlementMapper() {
        let config = PurchaseConfiguration(entitlementMapper: { _ in "premium" })

        #expect(config.entitlementMapper?("anything") == "premium")
    }
}
