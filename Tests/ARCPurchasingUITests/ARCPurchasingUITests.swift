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
/// Behavioral testing requires a configured `Purchases.shared` instance
/// and happens in the Example app.
@MainActor
@Suite("ARCPurchasingUI Compile Verification")
struct ARCPurchasingUITests {
    // MARK: - Helpers

    // swiftlint:disable force_unwrapping
    private static let demoConfig = PaywallConfiguration(headerLabel: "TEST PREMIUM",
                                                         title: "Test Title",
                                                         subtitle: "Test subtitle",
                                                         iconName: "star",
                                                         features: [.init(highlightedText: "Feature one",
                                                                          description: "description")],
                                                         ctaButtonTitle: "Subscribe",
                                                         termsOfServiceURL: URL(string: "https://example.com/terms")!,
                                                         privacyPolicyURL: URL(string: "https://example.com/privacy")!)
    // swiftlint:enable force_unwrapping

    // MARK: - View Instantiation

    @Test("ARCPaywallView initializes with configuration only") func arcPaywallView_configOnly() {
        _ = ARCPaywallView(configuration: Self.demoConfig)
    }

    @Test("ARCPaywallView initializes with all arguments") func arcPaywallView_fullInit() {
        _ = ARCPaywallView(configuration: Self.demoConfig,
                           theme: .darkBurgundy,
                           onDismiss: {},
                           onPurchaseCompleted: {})
    }

    @Test("ARCPaywallView accepts lightGold theme") func arcPaywallView_lightGoldTheme() {
        _ = ARCPaywallView(configuration: Self.demoConfig, theme: .lightGold)
    }

    // MARK: - Configuration

    @Test("PaywallConfiguration Feature initializes correctly") func feature_init() {
        let feature = PaywallConfiguration.Feature(highlightedText: "Bold part",
                                                   description: "regular part")
        #expect(feature.highlightedText == "Bold part")
        #expect(feature.description == "regular part")
        #expect(feature.iconName == "checkmark.circle.fill")
    }

    @Test("PaywallConfiguration Feature accepts custom icon") func feature_customIcon() {
        let feature = PaywallConfiguration.Feature(highlightedText: "Title",
                                                   description: "Desc",
                                                   iconName: "star.fill")
        #expect(feature.iconName == "star.fill")
    }

    // MARK: - Modifier API Surface

    @Test("presentARCPaywall modifier is callable") func presentARCPaywall_isCallable() {
        @State var isPresented = false
        let result = Text("test").presentARCPaywall(isPresented: $isPresented,
                                                    configuration: Self.demoConfig)
        _ = type(of: result)
    }

    @Test("presentARCPaywall modifier accepts custom theme") func presentARCPaywall_customTheme() {
        @State var isPresented = false
        let result = Text("test").presentARCPaywall(isPresented: $isPresented,
                                                    configuration: Self.demoConfig,
                                                    theme: .lightGold)
        _ = type(of: result)
    }

    @Test("presentARCPaywallIfNeeded modifier is callable") func presentARCPaywallIfNeeded_isCallable() {
        let result = Text("test").presentARCPaywallIfNeeded(entitlement: "premium",
                                                            configuration: Self.demoConfig)
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

    @available(iOS 18.0, *)
    @Test("presentARCCustomerCenter modifier is callable") func presentARCCustomerCenter_isCallable() {
        @State var isPresented = false
        let result = Text("test").presentARCCustomerCenter(isPresented: $isPresented)
        _ = type(of: result)
    }
}
#endif
