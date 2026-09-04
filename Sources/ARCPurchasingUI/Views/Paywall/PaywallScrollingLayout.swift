//
//  PaywallScrollingLayout.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import ARCPurchasing
import SwiftUI

/// Paywall layout for accessibility content sizes.
///
/// The pinned bottom block dissolves: header, features, products, CTA and footer all live in
/// one scrolling column, so every benefit stays reachable and no label has to truncate to fit.
struct PaywallScrollingLayout: View {
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
        ScrollView {
            VStack(spacing: 16) {
                PaywallHeaderView(configuration: configuration,
                                  theme: theme)

                if !configuration.features.isEmpty {
                    PaywallFeatureListView(features: configuration.features,
                                           theme: theme)
                }

                PaywallProductsSection(subscriptionProducts: subscriptionProducts,
                                       lifetimeProduct: lifetimeProduct,
                                       selectedProductID: selectedProductID,
                                       highlightedProductID: configuration.highlightedProductID,
                                       lifetimeSubtitle: configuration.lifetimeSubtitle,
                                       badges: badges,
                                       layoutMode: .scrolling,
                                       theme: theme,
                                       onSelect: onSelect)

                PaywallContinueButton(title: configuration.ctaButtonTitle,
                                      isLoading: isPurchasing,
                                      isDisabled: selectedProductID == nil,
                                      theme: theme,
                                      action: onPurchase)

                PaywallFooterView(renewalDisclosure: configuration.renewalDisclosure,
                                  termsOfServiceURL: configuration.termsOfServiceURL,
                                  privacyPolicyURL: configuration.privacyPolicyURL,
                                  layoutMode: .scrolling,
                                  theme: theme,
                                  onRestore: onRestore,
                                  isRestoring: isRestoring)
            }
            .padding(.bottom, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Previews

#Preview("Dark — AX5") {
    PaywallScrollingLayout(configuration: PaywallPreviewSample.configuration,
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
        .environment(\.dynamicTypeSize, .accessibility5)
}
