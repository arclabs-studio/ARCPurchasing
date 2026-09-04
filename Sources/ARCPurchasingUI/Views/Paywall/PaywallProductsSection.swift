//
//  PaywallProductsSection.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import ARCPurchasing
import SwiftUI

/// Selectable products block: subscription cards plus the optional lifetime card.
///
/// Shared by ``PaywallPinnedLayout`` and ``PaywallScrollingLayout`` so both layouts
/// present the same selection surface.
struct PaywallProductsSection: View {
    let subscriptionProducts: [PurchaseProduct]
    let lifetimeProduct: PurchaseProduct?
    let selectedProductID: String?
    let highlightedProductID: String?
    let lifetimeSubtitle: String?
    let badges: [String: String]
    let layoutMode: PaywallLayoutMode
    let theme: PaywallTheme
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            if !subscriptionProducts.isEmpty {
                PaywallSubscriptionCardsView(products: subscriptionProducts,
                                             selectedProductID: selectedProductID,
                                             highlightedProductID: highlightedProductID,
                                             badges: badges,
                                             layoutMode: layoutMode,
                                             theme: theme,
                                             onSelect: { onSelect($0.id) })
            }

            if let lifetimeProduct {
                PaywallLifetimeCardView(product: lifetimeProduct,
                                        subtitle: lifetimeSubtitle,
                                        isSelected: selectedProductID == lifetimeProduct.id,
                                        layoutMode: layoutMode,
                                        theme: theme,
                                        onTap: { onSelect(lifetimeProduct.id) })
            }
        }
    }
}

// MARK: - Previews

#Preview("Dark") {
    PaywallProductsSection(subscriptionProducts: Array(ARCPaywallView.previewMockProducts.prefix(2)),
                           lifetimeProduct: ARCPaywallView.previewMockProducts.last,
                           selectedProductID: "com.app.premium.yearly",
                           highlightedProductID: "com.app.premium.yearly",
                           lifetimeSubtitle: "One-time purchase · Limited offer",
                           badges: ["com.app.premium.yearly": "SAVE 42%"],
                           layoutMode: .pinned,
                           theme: .darkBurgundy,
                           onSelect: { _ in })
        .padding(.vertical, 24)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Dark — AX5") {
    ScrollView {
        PaywallProductsSection(subscriptionProducts: Array(ARCPaywallView.previewMockProducts.prefix(2)),
                               lifetimeProduct: ARCPaywallView.previewMockProducts.last,
                               selectedProductID: "com.app.premium.yearly",
                               highlightedProductID: "com.app.premium.yearly",
                               lifetimeSubtitle: "One-time purchase · Limited offer",
                               badges: ["com.app.premium.yearly": "SAVE 42%"],
                               layoutMode: .scrolling,
                               theme: .darkBurgundy,
                               onSelect: { _ in })
            .padding(.vertical, 24)
    }
    .background(PaywallTheme.darkBurgundy.backgroundColor)
    .environment(\.dynamicTypeSize, .accessibility5)
}
