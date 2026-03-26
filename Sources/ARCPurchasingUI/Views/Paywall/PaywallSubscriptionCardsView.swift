//
//  PaywallSubscriptionCardsView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import ARCPurchasing
import SwiftUI

/// Side-by-side subscription product cards (e.g., Monthly | Yearly).
///
/// Handles selection state, savings badge overlay on the highlighted card,
/// and monthly-equivalent price display.
struct PaywallSubscriptionCardsView: View {
    let products: [PurchaseProduct]
    let selectedProductID: String?
    let highlightedProductID: String?
    let badges: [String: String] // productID -> badge text
    let theme: PaywallTheme
    let onSelect: (PurchaseProduct) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(products) { product in
                SubscriptionCard(product: product,
                                 isSelected: product.id == selectedProductID,
                                 isHighlighted: product.id == highlightedProductID,
                                 badge: badges[product.id],
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
    let badge: String?
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
        .overlay(alignment: .top) {
            if let badge {
                badgeView(badge)
                    .offset(y: -12)
            }
        }
    }

    private var cardContent: some View {
        VStack(spacing: 4) {
            // Period label (e.g., "MONTHLY", "YEARLY")
            Text(periodLabel)
                .font(.caption.weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(theme.secondaryTextColor)

            // Price
            Text(product.displayPrice)
                .font(.title2.bold())
                .foregroundStyle(theme.primaryTextColor)

            // Monthly equivalent or "per month" label
            Text(bottomLabel)
                .font(.caption)
                .foregroundStyle(theme.secondaryTextColor)
        }
    }

    private func badgeView(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(theme.ctaTextColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(theme.accentColor)
            .clipShape(Capsule())
    }

    /// "MONTHLY" / "YEARLY" / period-based label
    private var periodLabel: String {
        guard let period = product.subscriptionPeriod else {
            return product.displayName.uppercased()
        }
        switch (period.value, period.unit) {
        case (1, .month): return "MONTHLY"
        case (1, .year), (12, .month): return "YEARLY"
        case (3, .month): return "QUARTERLY"
        case (6, .month): return "6 MONTHS"
        default:
            if period.value == 1 {
                return period.unit.rawValue.uppercased()
            }
            return "\(period.value) \(period.unit.rawValue.uppercased())S"
        }
    }

    /// Shows monthly equivalent for yearly; "per month" for monthly
    private var bottomLabel: String {
        guard let period = product.subscriptionPeriod else { return "" }
        let totalMonths = period.totalMonths
        guard totalMonths > 1 else { return "per month" }
        // Monthly equivalent
        let equivalent = product.price / Decimal(totalMonths)
        let formatted = formatDecimal(equivalent, currencyCode: product.currencyCode)
        return "\(formatted)/month"
    }
}

// MARK: - Helpers

private func formatDecimal(_ value: Decimal, currencyCode: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
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
                                        badges: ["yearly": "SAVE 42%"],
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
                                        badges: ["yearly": "SAVE 42%"],
                                        theme: .lightGold,
                                        onSelect: { _ in })
        .padding(.vertical, 24)
        .background(PaywallTheme.lightGold.backgroundColor)
}
