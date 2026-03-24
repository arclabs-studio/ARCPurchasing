//
//  ARCPurchasingUITests.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import ARCPurchasing
import ARCPurchasingUI
import SwiftUI
import Testing

/// Compile-time verification that ARCPurchasingUI types and modifiers are accessible.
///
/// These tests verify the public API surface compiles without errors.
/// Behavioral testing of RevenueCatUI wrappers requires a configured `Purchases.shared`
/// instance and happens in the Example app.
@MainActor
@Suite("ARCPurchasingUI Compile Verification")
struct ARCPurchasingUITests {
    // MARK: - View Instantiation

    @Test("ARCPaywallView initializes with default arguments") func arcPaywallView_defaultInit() {
        _ = ARCPaywallView()
    }

    @Test("ARCPaywallView initializes with all arguments") func arcPaywallView_fullInit() {
        _ = ARCPaywallView(offeringIdentifier: "annual_sale",
                           onDismiss: {},
                           onPurchaseCompleted: {})
    }

    // MARK: - Modifier API Surface

    @Test("presentARCPaywall modifier is callable") func presentARCPaywall_isCallable() {
        @State var isPresented = false
        // Verify the method exists and returns some View
        let result = Text("test").presentARCPaywall(isPresented: $isPresented)
        _ = type(of: result)
    }

    @Test("presentARCPaywallIfNeeded modifier is callable") func presentARCPaywallIfNeeded_isCallable() {
        let result = Text("test").presentARCPaywallIfNeeded(entitlement: "premium")
        _ = type(of: result)
    }
}

#if os(iOS)
@MainActor
extension ARCPurchasingUITests {
    @available(iOS 18.0, *)
    @Test("ARCCustomerCenterView initializes with default arguments") func arcCustomerCenterView_defaultInit() {
        _ = ARCCustomerCenterView()
    }

    @available(iOS 18.0, *)
    @Test("ARCCustomerCenterView initializes with onDismiss") func arcCustomerCenterView_withDismiss() {
        _ = ARCCustomerCenterView(onDismiss: {})
    }

    @Test("arcPaywallFooter modifier is callable") func arcPaywallFooter_isCallable() {
        let result = Text("test").arcPaywallFooter()
        _ = type(of: result)
    }

    @available(iOS 18.0, *)
    @Test("presentARCCustomerCenter modifier is callable") func presentARCCustomerCenter_isCallable() {
        @State var isPresented = false
        let result = Text("test").presentARCCustomerCenter(isPresented: $isPresented)
        _ = type(of: result)
    }
}
#endif
