//
//  PaywallPinnedLayout.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import ARCPurchasing
import SwiftUI

/// Paywall layout for standard content sizes.
///
/// The header and the feature list scroll; the products, the CTA and the footer stay pinned
/// to the bottom so the selection sits next to the action it drives.
struct PaywallPinnedLayout: View {
    let configuration: PaywallConfiguration
    let theme: PaywallTheme
    let subscriptionProducts: [PurchaseProduct]
    let lifetimeProduct: PurchaseProduct?
    let selectedProductID: String?
    let badges: [String: PaywallBadge]
    let isPurchasing: Bool
    let isRestoring: Bool
    let onSelect: (String) -> Void
    let onPurchase: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    PaywallHeaderView(configuration: configuration,
                                      theme: theme)

                    if !configuration.features.isEmpty {
                        PaywallFeatureListView(features: configuration.features,
                                               theme: theme)
                    }
                }
                .padding(.bottom, 12)
            }
            .scrollBounceBehavior(.basedOnSize)

            // Pinned bottom: products + CTA + footer always visible
            VStack(spacing: 0) {
                // Products pinned above CTA — keeps selection spatially adjacent to action
                PaywallProductsSection(subscriptionProducts: subscriptionProducts,
                                       lifetimeProduct: lifetimeProduct,
                                       selectedProductID: selectedProductID,
                                       highlightedProductID: configuration.highlightedProductID,
                                       lifetimeSubtitle: configuration.lifetimeSubtitle,
                                       badges: badges,
                                       layoutMode: .pinned,
                                       theme: theme,
                                       onSelect: onSelect)
                    .padding(.vertical, 16)

                PaywallContinueButton(title: configuration.ctaButtonTitle,
                                      isLoading: isPurchasing,
                                      isDisabled: selectedProductID == nil,
                                      theme: theme,
                                      action: onPurchase)

                PaywallFooterView(renewalDisclosure: configuration.renewalDisclosure,
                                  termsOfServiceURL: configuration.termsOfServiceURL,
                                  privacyPolicyURL: configuration.privacyPolicyURL,
                                  layoutMode: .pinned,
                                  theme: theme,
                                  onRestore: onRestore,
                                  isRestoring: isRestoring)
            }
            .padding(.top, 8)
            .background(theme.backgroundColor)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
            .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: -4)
        }
    }
}

// MARK: - Previews

#Preview("Dark") {
    PaywallPinnedLayout(configuration: PaywallPreviewSample.configuration,
                        theme: .darkBurgundy,
                        subscriptionProducts: PaywallPreviewSample.subscriptions,
                        lifetimeProduct: PaywallPreviewSample.lifetime,
                        selectedProductID: PaywallPreviewSample.selectedProductID,
                        badges: PaywallPreviewSample.badges,
                        isPurchasing: false,
                        isRestoring: false,
                        onSelect: { _ in },
                        onPurchase: {},
                        onRestore: {})
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}
