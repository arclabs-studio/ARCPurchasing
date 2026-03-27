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
    let theme: PaywallTheme
    let onRestore: () -> Void
    let isRestoring: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Renewal disclosure
            if let renewalDisclosure {
                Text(renewalDisclosure)
                    .font(.caption2)
                    .foregroundStyle(theme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }

            // Links row: Restore · Terms · Privacy
            HStack(spacing: 0) {
                restoreButton
                separator
                termsLink
                separator
                privacyLink
            }
            .font(.caption2)
            .foregroundStyle(theme.secondaryTextColor)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
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
            }
        }
        .disabled(isRestoring)
        .foregroundStyle(theme.secondaryTextColor)
    }

    private var separator: some View {
        Text(" · ")
            .foregroundStyle(theme.secondaryTextColor)
    }

    private var termsLink: some View {
        Link("Terms", destination: termsOfServiceURL)
            .underline()
            .foregroundStyle(theme.secondaryTextColor)
    }

    private var privacyLink: some View {
        Link("Privacy", destination: privacyPolicyURL)
            .underline()
            .foregroundStyle(theme.secondaryTextColor)
    }
}

// MARK: - Previews

// swiftlint:disable force_unwrapping
private let _previewTOS = URL(string: "https://example.com/terms")!
private let _previewPrivacy = URL(string: "https://example.com/privacy")!
// swiftlint:enable force_unwrapping

#Preview("Dark") {
    PaywallFooterView(renewalDisclosure: "Renews automatically. Cancel anytime.",
                      termsOfServiceURL: _previewTOS,
                      privacyPolicyURL: _previewPrivacy,
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
                      theme: .lightGold,
                      onRestore: {},
                      isRestoring: false)
        .padding(.vertical)
        .background(PaywallTheme.lightGold.backgroundColor)
}
