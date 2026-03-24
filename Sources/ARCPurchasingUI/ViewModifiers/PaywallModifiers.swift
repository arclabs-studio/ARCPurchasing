//
//  PaywallModifiers.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import ARCPurchasing
import RevenueCat
import RevenueCatUI
import SwiftUI

public extension View {
    /// Present an `ARCPaywallView` as a sheet.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls sheet presentation.
    ///   - offeringIdentifier: Optional RC offering identifier. If `nil`, the default offering is used.
    ///   - onPurchaseCompleted: Called after a successful purchase or restore.
    func presentARCPaywall(isPresented: Binding<Bool>,
                           offeringIdentifier: String? = nil,
                           onPurchaseCompleted: (() -> Void)? = nil) -> some View {
        sheet(isPresented: isPresented) {
            ARCPaywallView(offeringIdentifier: offeringIdentifier,
                           onDismiss: { isPresented.wrappedValue = false },
                           onPurchaseCompleted: {
                               isPresented.wrappedValue = false
                               onPurchaseCompleted?()
                           })
        }
    }

    /// Present an `ARCPaywallView` as a sheet only when the user lacks the given entitlement.
    ///
    /// Checks `ARCPurchaseManager.shared.hasEntitlement(_:)` on appear. If the entitlement
    /// is already active, the sheet is not presented.
    ///
    /// - Parameters:
    ///   - entitlement: The entitlement identifier required to suppress the paywall.
    ///   - offeringIdentifier: Optional RC offering identifier. If `nil`, the default offering is used.
    ///   - onPurchaseCompleted: Called after a successful purchase or restore.
    func presentARCPaywallIfNeeded(entitlement: String,
                                   offeringIdentifier: String? = nil,
                                   onPurchaseCompleted: (() -> Void)? = nil) -> some View {
        modifier(PaywallIfNeededModifier(entitlement: entitlement,
                                         offeringIdentifier: offeringIdentifier,
                                         onPurchaseCompleted: onPurchaseCompleted))
    }
}

#if os(iOS)
public extension View {
    /// Attach a paywall footer below this view's content.
    ///
    /// Wraps RevenueCatUI's `.paywallFooter()` and automatically refreshes
    /// `ARCPurchaseManager` state after purchases.
    ///
    /// - Parameters:
    ///   - offeringIdentifier: Optional RC offering identifier. If `nil`, the default offering is used.
    ///   - condensed: When `true`, renders the condensed footer variant.
    ///   - onPurchaseCompleted: Called after a successful purchase or restore.
    func arcPaywallFooter(offeringIdentifier: String? = nil,
                          condensed: Bool = false,
                          onPurchaseCompleted: (() -> Void)? = nil) -> some View {
        modifier(PaywallFooterModifier(offeringIdentifier: offeringIdentifier,
                                       condensed: condensed,
                                       onPurchaseCompleted: onPurchaseCompleted))
    }
}

// MARK: - PaywallFooterModifier

private struct PaywallFooterModifier: ViewModifier {
    let offeringIdentifier: String?
    let condensed: Bool
    let onPurchaseCompleted: (() -> Void)?

    @State private var purchaseManager = ARCPurchaseManager.shared
    @State private var offering: Offering?

    func body(content: Content) -> some View {
        paywallFooterView(content: content)
            .task(id: offeringIdentifier) {
                await resolveOffering()
            }
    }

    @ViewBuilder private func paywallFooterView(content: Content) -> some View {
        if let offering {
            if condensed {
                content
                    .paywallFooter(offering: offering, condensed: true) { _ in
                        Task { await purchaseManager.refreshState() }
                        onPurchaseCompleted?()
                    }
            } else {
                content
                    .paywallFooter(offering: offering) { _ in
                        Task { await purchaseManager.refreshState() }
                        onPurchaseCompleted?()
                    }
            }
        } else {
            if condensed {
                content
                    .paywallFooter(condensed: true) { _ in
                        Task { await purchaseManager.refreshState() }
                        onPurchaseCompleted?()
                    }
            } else {
                content
                    .paywallFooter { _ in
                        Task { await purchaseManager.refreshState() }
                        onPurchaseCompleted?()
                    }
            }
        }
    }

    private func resolveOffering() async {
        guard let offeringIdentifier, purchaseManager.isConfigured else { return }
        // ARCPurchasingUI is intentionally RevenueCat-coupled; Offering is a RevenueCat
        // type required by paywallFooter. Falls back to default offering on failure.
        do {
            offering = try await Purchases.shared.offerings().offering(identifier: offeringIdentifier)
        } catch {
            // Falls back to paywallFooter() which uses the current default offering.
        }
    }
}
#endif

// MARK: - PaywallIfNeededModifier

private struct PaywallIfNeededModifier: ViewModifier {
    let entitlement: String
    let offeringIdentifier: String?
    let onPurchaseCompleted: (() -> Void)?

    @State private var isPresented = false
    @State private var purchaseManager = ARCPurchaseManager.shared

    func body(content: Content) -> some View {
        content
            .presentARCPaywall(isPresented: $isPresented,
                               offeringIdentifier: offeringIdentifier,
                               onPurchaseCompleted: onPurchaseCompleted)
            .task {
                let hasEntitlement = await purchaseManager.hasEntitlement(entitlement)
                if !hasEntitlement {
                    isPresented = true
                }
            }
    }
}
