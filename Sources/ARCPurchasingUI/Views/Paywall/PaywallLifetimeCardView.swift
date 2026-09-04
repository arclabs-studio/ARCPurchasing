//
//  PaywallLifetimeCardView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import ARCPurchasing
import SwiftUI

/// Full-width lifetime / one-time purchase card with a dashed border.
///
/// Shown below the subscription cards when `PaywallConfiguration.lifetimeProductID`
/// is set and the corresponding product is loaded.
struct PaywallLifetimeCardView: View {
    let product: PurchaseProduct
    let subtitle: String?
    let isSelected: Bool
    let layoutMode: PaywallLayoutMode
    let theme: PaywallTheme
    let onTap: () -> Void

    var body: some View {
        // AnyLayout keeps the card's identity across the swap; the price moves below the
        // label at accessibility sizes, where a side-by-side row could only truncate
        let layout = layoutMode == .scrolling
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))

        Button(action: onTap) {
            layout {
                // Label + subtitle. Growing to the full width replaces the Spacer a
                // vertical layout could not use.
                VStack(alignment: .leading, spacing: 2) {
                    Text("LIFETIME ACCESS")
                        .font(.footnote.weight(.bold))
                        .tracking(0.5)
                        .foregroundStyle(theme.primaryTextColor)
                        .wrappingText()

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryTextColor)
                            .wrappingText()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Price — never truncated, at any content size
                Text(product.displayPrice)
                    .font(.title3.bold())
                    .foregroundStyle(theme.primaryTextColor)
                    .wrappingText()
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(theme.cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                .strokeBorder(isSelected ? theme.selectedCardBorderColor : theme.lifetimeCardBorderColor,
                              style: StrokeStyle(lineWidth: isSelected ? 2 : 1.5,
                                                 dash: isSelected ? [] : [6, 4])))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }
}

// MARK: - Previews

#Preview("Dark") {
    let lifetime = PurchaseProduct(id: "lifetime", displayName: "Lifetime Access", description: "",
                                   price: 89.99, displayPrice: "$89.99", currencyCode: "USD",
                                   type: .nonConsumable)
    return VStack(spacing: 16) {
        PaywallLifetimeCardView(product: lifetime,
                                subtitle: "One-time purchase · Limited offer",
                                isSelected: false,
                                layoutMode: .pinned,
                                theme: .darkBurgundy,
                                onTap: {})
        PaywallLifetimeCardView(product: lifetime,
                                subtitle: "One-time purchase · Limited offer",
                                isSelected: true,
                                layoutMode: .pinned,
                                theme: .darkBurgundy,
                                onTap: {})
    }
    .padding(.vertical)
    .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    let lifetime = PurchaseProduct(id: "lifetime", displayName: "Lifetime Access", description: "",
                                   price: 89.99, displayPrice: "$89.99", currencyCode: "USD",
                                   type: .nonConsumable)
    return PaywallLifetimeCardView(product: lifetime,
                                   subtitle: "One-time purchase · Limited offer",
                                   isSelected: false,
                                   layoutMode: .pinned,
                                   theme: .lightGold,
                                   onTap: {})
        .padding(.vertical)
        .background(PaywallTheme.lightGold.backgroundColor)
}

#Preview("Dark — AX5") {
    let lifetime = PurchaseProduct(id: "lifetime", displayName: "Lifetime Access", description: "",
                                   price: 89.99, displayPrice: "$89.99", currencyCode: "USD",
                                   type: .nonConsumable)
    return ScrollView {
        PaywallLifetimeCardView(product: lifetime,
                                subtitle: "One-time purchase · Limited offer",
                                isSelected: true,
                                layoutMode: .scrolling,
                                theme: .darkBurgundy,
                                onTap: {})
            .padding(.vertical)
    }
    .background(PaywallTheme.darkBurgundy.backgroundColor)
    .environment(\.dynamicTypeSize, .accessibility5)
}
