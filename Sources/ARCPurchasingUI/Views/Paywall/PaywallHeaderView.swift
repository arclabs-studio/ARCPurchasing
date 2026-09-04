//
//  PaywallHeaderView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import SwiftUI

/// Header section of the paywall.
///
/// Renders: icon badge, title, subtitle.
struct PaywallHeaderView: View {
    let configuration: PaywallConfiguration
    let theme: PaywallTheme

    /// Icon chrome is fixed-size by nature, so it scales with the content size explicitly.
    @ScaledMetric(relativeTo: .largeTitle) private var badgeSize: CGFloat = 64

    var body: some View {
        VStack(spacing: 12) {
            // Icon badge
            if configuration.iconAssetName != nil || configuration.iconName != nil {
                iconBadge
            }

            // Title
            Text(configuration.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.primaryTextColor)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            // Subtitle
            if let subtitle = configuration.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.accentTextColor)
                    .wrappingText()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }

    @ViewBuilder private var iconBadge: some View {
        if let assetName = configuration.iconAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: badgeSize, height: badgeSize)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else if let name = configuration.iconName {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.accentColor)
                    .frame(width: badgeSize, height: badgeSize)

                Image(systemName: name)
                    .font(.title.weight(.medium))
                    .foregroundStyle(theme.ctaTextColor)
            }
        }
    }
}

private let _previewConfig = PaywallConfiguration(headerLabel: "FORKS PREMIUM",
                                                  title: "Unlock the full\nForks experience",
                                                  subtitle: "Your food journey, without limits",
                                                  iconName: "fork.knife",
                                                  termsOfServiceURL: URL(string: "https://example.com/terms") ??
                                                      URL(fileURLWithPath: "/"),
                                                  privacyPolicyURL: URL(string: "https://example.com/privacy") ??
                                                      URL(fileURLWithPath: "/"))

#Preview("Dark") {
    PaywallHeaderView(configuration: _previewConfig, theme: .darkBurgundy)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    PaywallHeaderView(configuration: _previewConfig, theme: .lightGold)
        .background(PaywallTheme.lightGold.backgroundColor)
}

#Preview("Dark — AX5") {
    ScrollView {
        PaywallHeaderView(configuration: _previewConfig, theme: .darkBurgundy)
    }
    .background(PaywallTheme.darkBurgundy.backgroundColor)
    .environment(\.dynamicTypeSize, .accessibility5)
}
