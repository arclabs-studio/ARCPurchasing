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

    /// Scales the ≥44pt touch target with the content size instead of pinning it to 56pt,
    /// which forced the title to truncate at accessibility sizes.
    @ScaledMetric(relativeTo: .headline) private var minHeight: CGFloat = 56

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(theme.ctaTextColor)
                } else {
                    // App-supplied copy — already localized by the app, never a key
                    Text(verbatim: title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(theme.ctaTextColor)
                        .multilineTextAlignment(.center)
                        .wrappingText()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: minHeight)
            .background(theme.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        }
        .disabled(isDisabled || isLoading)
        // The title Text disappears while loading, leaving the button unlabelled otherwise.
        // Explicit Text values: our own copy localizes, the app-supplied title stays verbatim.
        .accessibilityLabel(isLoading ? Text("Processing purchase") : Text(verbatim: title))
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

#Preview("Dark — AX5") {
    PaywallContinueButton(title: "Start Premium",
                          isLoading: false,
                          isDisabled: false,
                          theme: .darkBurgundy,
                          action: {})
        .padding(.vertical)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
        .environment(\.dynamicTypeSize, .accessibility5)
}
