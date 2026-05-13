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
        // Arrange & Act
        let config = PurchaseConfiguration(apiKey: "test_key",
                                           userID: "user_123",
                                           debugLoggingEnabled: true,
                                           storeKitVersion: .storeKit1,
                                           entitlementIdentifiers: ["premium", "pro"])

        // Assert
        #expect(config.apiKey == "test_key")
        #expect(config.userID == "user_123")
        #expect(config.debugLoggingEnabled == true)
        #expect(config.storeKitVersion == .storeKit1)
        #expect(config.entitlementIdentifiers == ["premium", "pro"])
    }

    @Test("Default values are correct") func initialization_defaultValues() {
        // Arrange & Act
        let config = PurchaseConfiguration(apiKey: "test_key")

        // Assert
        #expect(config.userID == nil)
        #expect(config.debugLoggingEnabled == false)
        #expect(config.storeKitVersion == .storeKit2)
        #expect(config.entitlementIdentifiers.isEmpty)
    }

    // MARK: - Validation Tests

    @Test("Valid API key passes validation") func validate_validAPIKey_succeeds() throws {
        let config = PurchaseConfiguration.mock()
        try config.validate()
    }

    @Test("Empty API key throws invalidConfiguration") func validate_emptyAPIKey_throwsInvalidConfiguration() {
        let config = PurchaseConfiguration(apiKey: "")
        #expect(throws: PurchaseError.self) {
            try config.validate()
        }
    }

    @Test("Whitespace-only API key throws invalidConfiguration") func validate_whitespaceAPIKey_throwsInvalidConfiguration() {
        let config = PurchaseConfiguration(apiKey: "   \n  ")
        #expect(throws: PurchaseError.self) {
            try config.validate()
        }
    }
}
