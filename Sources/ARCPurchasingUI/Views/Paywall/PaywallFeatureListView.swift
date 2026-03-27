//
//  PaywallFeatureListView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import SwiftUI

/// Stacked list of feature rows, each with a checkmark icon and rich text.
///
/// Each row renders as: `[icon]  **highlightedText** description`
struct PaywallFeatureListView: View {
    let features: [PaywallConfiguration.Feature]
    let theme: PaywallTheme

    var body: some View {
        VStack(spacing: 10) {
            ForEach(features) { feature in
                FeatureRowView(feature: feature, theme: theme)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - FeatureRowView

private struct FeatureRowView: View {
    let feature: PaywallConfiguration.Feature
    let theme: PaywallTheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            Image(systemName: feature.iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(theme.accentColor)
                .frame(width: 24, height: 24)
                .padding(6)
                .background(theme.accentColor.opacity(0.15))
                .clipShape(Circle())

            // Rich text: bold highlighted + regular description
            richText
                .font(.subheadline)
                .foregroundStyle(theme.primaryTextColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(theme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius - 4, style: .continuous))
    }

    private var richText: Text {
        Text(feature.highlightedText)
            .fontWeight(.bold)
            .foregroundStyle(theme.accentTextColor)
            + Text(" ")
            + Text(feature.description)
    }
}

// MARK: - Previews

#Preview("Dark") {
    PaywallFeatureListView(features: [.init(highlightedText: "Year in Food",
                                            description: "— full annual stats & insights"),
                                      .init(highlightedText: "AI recommendations",
                                            description: "tailored to your taste"),
                                      .init(highlightedText: "Export & share", description: "your lists anywhere"),
                                      .init(highlightedText: "Visual themes",
                                            description: "to personalize your profile")],
                           theme: .darkBurgundy)
        .padding(.vertical)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    PaywallFeatureListView(features: [.init(highlightedText: "Year in Food",
                                            description: "— full annual stats & insights"),
                                      .init(highlightedText: "AI recommendations",
                                            description: "tailored to your taste"),
                                      .init(highlightedText: "Export & share", description: "your lists anywhere"),
                                      .init(highlightedText: "Visual themes",
                                            description: "to personalize your profile")],
                           theme: .lightGold)
        .padding(.vertical)
        .background(PaywallTheme.lightGold.backgroundColor)
}
