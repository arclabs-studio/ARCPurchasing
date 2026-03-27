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

    var body: some View {
        VStack(spacing: 12) {
            // Icon badge
            if let iconName = configuration.iconName {
                iconBadge(named: iconName)
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
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }

    private func iconBadge(named name: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.accentColor)
                .frame(width: 64, height: 64)

            Image(systemName: name)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(theme.ctaTextColor)
        }
    }
}

// swiftlint:disable force_unwrapping
private let _previewConfig = PaywallConfiguration(headerLabel: "FORKS PREMIUM",
                                                  title: "Unlock the full\nForks experience",
                                                  subtitle: "Your food journey, without limits",
                                                  iconName: "fork.knife",
                                                  termsOfServiceURL: URL(string: "https://example.com/terms")!,
                                                  privacyPolicyURL: URL(string: "https://example.com/privacy")!)
// swiftlint:enable force_unwrapping

#Preview("Dark") {
    PaywallHeaderView(configuration: _previewConfig, theme: .darkBurgundy)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    PaywallHeaderView(configuration: _previewConfig, theme: .lightGold)
        .background(PaywallTheme.lightGold.backgroundColor)
}
