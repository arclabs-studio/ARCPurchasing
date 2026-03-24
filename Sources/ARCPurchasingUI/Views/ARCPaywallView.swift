//
//  ARCPaywallView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import ARCPurchasing
import RevenueCat
import RevenueCatUI
import SwiftUI

/// A full-screen paywall view backed by RevenueCat.
///
/// `ARCPaywallView` wraps RevenueCatUI's `PaywallView`, automatically
/// refreshing `ARCPurchaseManager` state after purchases and tracking
/// analytics events.
///
/// ## Usage
///
/// ```swift
/// struct PremiumScreen: View {
///     @Environment(\.dismiss) private var dismiss
///
///     var body: some View {
///         ARCPaywallView(onDismiss: { dismiss() })
///     }
/// }
/// ```
///
/// To target a specific RC offering:
///
/// ```swift
/// ARCPaywallView(offeringIdentifier: "annual_sale")
/// ```
public struct ARCPaywallView: View {
    // MARK: - Properties

    private let offeringIdentifier: String?
    private let onDismiss: (() -> Void)?
    private let onPurchaseCompleted: (() -> Void)?

    @State private var purchaseManager = ARCPurchaseManager.shared
    @State private var offering: Offering?

    // MARK: - Initialization

    /// Creates a paywall view.
    ///
    /// - Parameters:
    ///   - offeringIdentifier: Optional RC offering identifier. If `nil`, the default current offering is used.
    ///   - onDismiss: Called when the user dismisses the paywall without purchasing.
    ///   - onPurchaseCompleted: Called after a successful purchase or restore.
    public init(offeringIdentifier: String? = nil,
                onDismiss: (() -> Void)? = nil,
                onPurchaseCompleted: (() -> Void)? = nil) {
        self.offeringIdentifier = offeringIdentifier
        self.onDismiss = onDismiss
        self.onPurchaseCompleted = onPurchaseCompleted
    }

    // MARK: - Body

    public var body: some View {
        paywallView
            .onPurchaseCompleted { _ in
                Task { await purchaseManager.refreshState() }
                onPurchaseCompleted?()
            }
            .onRestoreCompleted { _ in
                Task { await purchaseManager.refreshState() }
                onPurchaseCompleted?()
            }
            .task {
                await purchaseManager.track(.paywallViewed(paywallID: offeringIdentifier))
                await resolveOffering()
            }
        #if os(iOS)
            .onDismiss {
                Task {
                    await purchaseManager.track(.paywallDismissed(paywallID: offeringIdentifier))
                }
                onDismiss?()
            }
        #endif
    }

    // MARK: - Private

    @ViewBuilder private var paywallView: some View {
        if let offering {
            PaywallView(offering: offering)
        } else {
            PaywallView()
        }
    }
}

// MARK: - Private Helpers

private extension ARCPaywallView {
    func resolveOffering() async {
        guard let offeringIdentifier else { return }
        offering = try? await Purchases.shared.offerings().offering(identifier: offeringIdentifier)
    }
}
