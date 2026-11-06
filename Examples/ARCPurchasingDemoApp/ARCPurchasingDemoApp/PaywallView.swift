//
//  PaywallView.swift
//  ARCPurchasingDemoApp
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCPurchasing
import ARCPurchasingUI
import SwiftUI

/// Demo screen showing `ARCPaywallView` with mock products.
///
/// In production, omit `previewProducts` — the paywall fetches live products
/// from the configured provider automatically (StoreKit 2 in this demo).
struct DemoPaywallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var theme: DemoTheme = .dark

    var body: some View {
        ZStack(alignment: .bottom) {
            ARCPaywallView(configuration: demoConfiguration,
                           theme: theme == .dark ? .darkBurgundy : .lightGold,
                           previewProducts: ARCPaywallView.previewMockProducts,
                           onDismiss: { dismiss() })

            themePicker
        }
    }

    private var themePicker: some View {
        Picker("Theme", selection: $theme) {
            Text("Dark Burgundy").tag(DemoTheme.dark)
            Text("Light Gold").tag(DemoTheme.light)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.4)],
                                   startPoint: .top,
                                   endPoint: .bottom))
    }
}

private enum DemoTheme {
    case dark, light
}

// MARK: - Demo Configuration

private let demoConfiguration = PaywallConfiguration(headerLabel: "ARC DEMO PREMIUM",
                                                     title: "Unlock the full\nDemo experience",
                                                     subtitle: "Everything you need, nothing you don't",
                                                     iconName: "star.circle.fill",
                                                     features: [.init(highlightedText: "Unlimited access",
                                                                      description: "to all premium features"),
                                                                .init(highlightedText: "No ads",
                                                                      description: "enjoy a clean, "
                                                                          + "distraction-free experience"),
                                                                .init(highlightedText: "Priority support",
                                                                      description: "get help faster when you need it")],
                                                     highlightedProductID: "com.app.premium.yearly",
                                                     lifetimeProductID: "com.app.premium.lifetime",
                                                     lifetimeSubtitle: "One-time purchase · Limited offer",
                                                     ctaButtonTitle: "Get Premium",
                                                     renewalDisclosure: "Renews automatically. Cancel anytime.",
                                                     termsOfServiceURL: .demoLink("https://example.com/terms"),
                                                     privacyPolicyURL: .demoLink("https://example.com/privacy"))

// MARK: - Demo Links

private extension URL {
    /// Parses a hard-coded demo link. A literal that does not parse is a programmer error.
    static func demoLink(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Invalid demo URL literal: \(string)")
        }
        return url
    }
}

// MARK: - Previews

#Preview("Dark") {
    DemoPaywallScreen()
}

#Preview("Light") {
    DemoPaywallScreen()
}
