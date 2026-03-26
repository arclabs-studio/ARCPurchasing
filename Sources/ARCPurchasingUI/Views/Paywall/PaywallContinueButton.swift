//
//  PaywallContinueButton.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import SwiftUI

/// Full-width CTA button for the paywall.
///
/// Shows a `ProgressView` while a purchase is in progress and disables
/// interaction to prevent duplicate taps.
struct PaywallContinueButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let theme: PaywallTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(theme.ctaTextColor)
                } else {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(theme.ctaTextColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(theme.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        }
        .disabled(isDisabled || isLoading)
        .padding(.horizontal, 24)
    }
}

// MARK: - Previews

#Preview("Dark — idle") {
    PaywallContinueButton(title: "Start Premium",
                          isLoading: false,
                          isDisabled: false,
                          theme: .darkBurgundy,
                          action: {})
        .padding(.vertical)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Dark — loading") {
    PaywallContinueButton(title: "Start Premium",
                          isLoading: true,
                          isDisabled: false,
                          theme: .darkBurgundy,
                          action: {})
        .padding(.vertical)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    PaywallContinueButton(title: "Start Premium",
                          isLoading: false,
                          isDisabled: false,
                          theme: .lightGold,
                          action: {})
        .padding(.vertical)
        .background(PaywallTheme.lightGold.backgroundColor)
}
