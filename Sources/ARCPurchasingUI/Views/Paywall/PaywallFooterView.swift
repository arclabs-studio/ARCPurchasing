//
//  PaywallFooterView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import SwiftUI

/// Footer section of the paywall.
///
/// Renders: auto-renewal disclosure (optional), then "Restore · Terms · Privacy" links.
/// Required by App Store Review Guidelines.
struct PaywallFooterView: View {
    let renewalDisclosure: String?
    let termsOfServiceURL: URL
    let privacyPolicyURL: URL
    let layoutMode: PaywallLayoutMode
    let theme: PaywallTheme
    let onRestore: () -> Void
    let isRestoring: Bool

    var body: some View {
        // The interpuncts have no room left at accessibility sizes — the links stack instead
        let layout = layoutMode == .scrolling
            ? AnyLayout(VStackLayout(spacing: 10))
            : AnyLayout(HStackLayout(spacing: 0))

        VStack(spacing: 6) {
            // Renewal disclosure
            if let renewalDisclosure {
                Text(renewalDisclosure)
                    .font(.caption2)
                    .foregroundStyle(theme.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .wrappingText()
            }

            // Links: Restore · Terms · Privacy
            layout {
                restoreButton
                if layoutMode == .pinned {
                    separator
                }
                termsLink
                if layoutMode == .pinned {
                    separator
                }
                privacyLink
            }
            .font(.caption2)
            .multilineTextAlignment(.center)
            .foregroundStyle(theme.secondaryTextColor)
        }
        .padding(.horizontal, 24)
        // Detaches the disclosure from the CTA above and the links from the safe area below
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    private var restoreButton: some View {
        Button {
            onRestore()
        } label: {
            if isRestoring {
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(height: 16)
            } else {
                Text("Restore")
                    .underline()
                    .wrappingText()
            }
        }
        .disabled(isRestoring)
        .foregroundStyle(theme.secondaryTextColor)
        // Explicit Text values so both branches take the localizing initializer
        .accessibilityLabel(isRestoring ? Text("Restoring purchases") : Text("Restore purchases"))
    }

    private var separator: some View {
        Text(" · ")
            .foregroundStyle(theme.secondaryTextColor)
            // Decorative divider between links, not a piece of content
            .accessibilityHidden(true)
    }

    private var termsLink: some View {
        Link("Terms", destination: termsOfServiceURL)
            .underline()
            .wrappingText()
            .foregroundStyle(theme.secondaryTextColor)
    }

    private var privacyLink: some View {
        Link("Privacy", destination: privacyPolicyURL)
            .underline()
            .wrappingText()
            .foregroundStyle(theme.secondaryTextColor)
    }
}

// MARK: - Previews

private let _previewTOS = URL(string: "https://example.com/terms") ?? URL(fileURLWithPath: "/")
private let _previewPrivacy = URL(string: "https://example.com/privacy") ?? URL(fileURLWithPath: "/")

#Preview("Dark") {
    PaywallFooterView(renewalDisclosure: "Renews automatically. Cancel anytime.",
                      termsOfServiceURL: _previewTOS,
                      privacyPolicyURL: _previewPrivacy,
                      layoutMode: .pinned,
                      theme: .darkBurgundy,
                      onRestore: {},
                      isRestoring: false)
        .padding(.vertical)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
}

#Preview("Light") {
    PaywallFooterView(renewalDisclosure: "Renews automatically. Cancel anytime.",
                      termsOfServiceURL: _previewTOS,
                      privacyPolicyURL: _previewPrivacy,
                      layoutMode: .pinned,
                      theme: .lightGold,
                      onRestore: {},
                      isRestoring: false)
        .padding(.vertical)
        .background(PaywallTheme.lightGold.backgroundColor)
}

#Preview("Dark — AX5") {
    PaywallFooterView(renewalDisclosure: "Renews automatically. Cancel anytime.",
                      termsOfServiceURL: _previewTOS,
                      privacyPolicyURL: _previewPrivacy,
                      layoutMode: .scrolling,
                      theme: .darkBurgundy,
                      onRestore: {},
                      isRestoring: false)
        .padding(.vertical)
        .background(PaywallTheme.darkBurgundy.backgroundColor)
        .environment(\.dynamicTypeSize, .accessibility5)
}
