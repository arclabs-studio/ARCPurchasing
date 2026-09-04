//
//  PaywallSubscriptionCardsView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import ARCPurchasing
import SwiftUI

/// Subscription product cards (e.g., Monthly | Yearly).
///
/// Handles selection state, savings badge on the highlighted card, and
/// monthly-equivalent price display. The cards sit side by side at standard
/// content sizes and stack vertically at accessibility sizes, where there is no
/// horizontal room left for the text to grow into.
struct PaywallSubscriptionCardsView: View {
    let products: [PurchaseProduct]
    let selectedProductID: String?
    let highlightedProductID: String?
    let badges: [String: PaywallBadge] // productID -> badge
    let layoutMode: PaywallLayoutMode
    let theme: PaywallTheme
    let onSelect: (PurchaseProduct) -> Void

    var body: some View {
        // AnyLayout keeps card identity — and therefore selection state — across the swap
        let layout = layoutMode == .scrolling
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        layout {
            ForEach(products) { product in
                SubscriptionCard(product: product,
                                 isSelected: product.id == selectedProductID,
                                 isHighlighted: product.id == highlightedProductID,
                                 badge: badges[product.id],
                                 layoutMode: layoutMode,
                                 theme: theme,
                                 onTap: { onSelect(product) })
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - SubscriptionCard

private struct SubscriptionCard: View {
    let product: PurchaseProduct
    let isSelected: Bool
    let isHighlighted: Bool
    let badge: PaywallBadge?
    let layoutMode: PaywallLayoutMode
    let theme: PaywallTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            cardContent
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 12)
                .background(theme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .strokeBorder(isSelected ? theme.selectedCardBorderColor : theme.cardBorderColor,
                                  lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
        // The visible content already reads price + period + savings; VoiceOver gets the same
        // in one stop instead of two, plus the selection state the border alone can't convey
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .overlay(alignment: .top) {
            // The floating badge only fits the card at standard sizes; larger text renders it inline.
            // Hidden from VoiceOver — its text is folded into accessibilityLabel above, since as a
            // sibling overlay it isn't part of the button's accessibility element.
            if layoutMode == .pinned, let badge {
                badgeView(badge)
                    .offset(y: -12)
                    .accessibilityHidden(true)
            }
        }
    }

    /// Folds the visible lines into one VoiceOver stop. Composed as `Text` rather than a
    /// `String` so our own copy keeps the localizing initializer while store data stays verbatim.
    private var accessibilityLabel: Text {
        var label = product.paywallPeriodCopy.text
        label = label + separatorText + Text(verbatim: product.displayPrice)
        if let bottomCopy = product.paywallBottomCopy {
            label = label + separatorText + bottomCopy.text
        }
        if let badge {
            label = label + separatorText + badge.copy.text
        }
        return label
    }

    private var separatorText: Text {
        Text(verbatim: ", ")
    }

    private var cardContent: some View {
        VStack(spacing: 4) {
            if layoutMode == .scrolling, let badge {
                badgeView(badge)
                    .padding(.bottom, 2)
            }

            // Period label (e.g., "MONTHLY", "YEARLY")
            product.paywallPeriodCopy.text
                .font(.caption.weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(theme.secondaryTextColor)
                .wrappingText()

            // Price — never truncated, at any content size
            Text(verbatim: product.displayPrice)
                .font(.title2.bold())
                .foregroundStyle(theme.primaryTextColor)
                .wrappingText()

            // Monthly equivalent or "per month" label
            bottomLabelText
                .font(.caption)
                .foregroundStyle(theme.secondaryTextColor)
                .wrappingText()
        }
        .multilineTextAlignment(.center)
    }

    /// Products without a subscription period keep an empty line so the cards stay the
    /// same height whether or not there is a bottom label to show.
    private var bottomLabelText: Text {
        product.paywallBottomCopy?.text ?? Text(verbatim: "")
    }

    private func badgeView(_ badge: PaywallBadge) -> some View {
        badge.copy.text
            .font(.caption2.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(theme.ctaTextColor)
            .wrappingText()
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(theme.accentColor)
            .clipShape(Capsule())
    }
}

// MARK: - Previews

#Preview("Dark") {
    let monthly = PurchaseProduct(id: "monthly", displayName: "Monthly", description: "",
                                  price: 4.99, displayPrice: "$4.99", currencyCode: "USD",
                                  type: .autoRenewableSubscription,
                                  subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .month))
    let yearly = PurchaseProduct(id: "yearly", displayName: "Yearly", description: "",
                                 price: 34.99, displayPrice: "$34.99", currencyCode: "USD",
                                 type: .autoRenewableSubscription,
                                 subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .year))
    return PaywallSubscriptionCardsView(products: [monthly, yearly],
                                        selectedProductID: "yearly",
                                        highlightedProductID: "yearly",
                                        badges: ["yearly": .savings(42)],
                                        layoutMode: .pinned,
                                        theme: .darkBurgundy,
                                        onSelect: { _ in })
        .padding(.vertical, 24)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    let monthly = PurchaseProduct(id: "monthly", displayName: "Monthly", description: "",
                                  price: 4.99, displayPrice: "$4.99", currencyCode: "USD",
                                  type: .autoRenewableSubscription,
                                  subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .month))
    let yearly = PurchaseProduct(id: "yearly", displayName: "Yearly", description: "",
                                 price: 34.99, displayPrice: "$34.99", currencyCode: "USD",
                                 type: .autoRenewableSubscription,
                                 subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .year))
    return PaywallSubscriptionCardsView(products: [monthly, yearly],
                                        selectedProductID: "yearly",
                                        highlightedProductID: "yearly",
                                        badges: ["yearly": .savings(42)],
                                        layoutMode: .pinned,
                                        theme: .lightGold,
                                        onSelect: { _ in })
        .padding(.vertical, 24)
        .background(PaywallTheme.lightGold.backgroundColor)
}

#Preview("Dark — AX5") {
    let monthly = PurchaseProduct(id: "monthly", displayName: "Monthly", description: "",
                                  price: 4.99, displayPrice: "$4.99", currencyCode: "USD",
                                  type: .autoRenewableSubscription,
                                  subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .month))
    let yearly = PurchaseProduct(id: "yearly", displayName: "Yearly", description: "",
                                 price: 34.99, displayPrice: "$34.99", currencyCode: "USD",
                                 type: .autoRenewableSubscription,
                                 subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .year))
    return ScrollView {
        PaywallSubscriptionCardsView(products: [monthly, yearly],
                                     selectedProductID: "yearly",
                                     highlightedProductID: "yearly",
                                     badges: ["yearly": .savings(42)],
                                     layoutMode: .scrolling,
                                     theme: .darkBurgundy,
                                     onSelect: { _ in })
            .padding(.vertical, 24)
    }
    .background(PaywallTheme.darkBurgundy.backgroundColor)
    .environment(\.dynamicTypeSize, .accessibility5)
}
