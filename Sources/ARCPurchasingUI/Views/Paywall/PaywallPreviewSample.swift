//
//  PaywallPreviewSample.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import ARCPurchasing
import Foundation

/// Centralized sample data for the paywall previews.
///
/// Main-actor isolated because it reuses `ARCPaywallView.previewMockProducts`, which is,
/// and previews evaluate on the main actor anyway.
@MainActor
enum PaywallPreviewSample {
    static let products: [PurchaseProduct] = ARCPaywallView.previewMockProducts

    static let subscriptions: [PurchaseProduct] = Array(products.prefix(2))

    static let lifetime: PurchaseProduct? = products.last

    static let badges: [String: PaywallBadge] = ["com.app.premium.yearly": .savings(42)]

    static let selectedProductID = "com.app.premium.yearly"

    static let configuration = PaywallConfiguration(headerLabel: "SAMPLE PREMIUM",
                                                    title: "Unlock everything",
                                                    subtitle: "No limits, no interruptions",
                                                    iconName: "sparkles",
                                                    features: [.init(highlightedText: "Full stats",
                                                                     description: "— every insight unlocked"),
                                                               .init(highlightedText: "Smart suggestions",
                                                                     description: "tailored to you")],
                                                    highlightedProductID: selectedProductID,
                                                    lifetimeProductID: "com.app.premium.lifetime",
                                                    lifetimeSubtitle: "One-time purchase · Limited offer",
                                                    ctaButtonTitle: "Start Premium",
                                                    termsOfServiceURL: URL(string: "https://example.com/terms") ??
                                                        URL(fileURLWithPath: "/"),
                                                    privacyPolicyURL: URL(string: "https://example.com/privacy") ??
                                                        URL(fileURLWithPath: "/"))
}
