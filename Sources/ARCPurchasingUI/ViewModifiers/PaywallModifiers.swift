//
//  PaywallModifiers.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import ARCPurchasing
import SwiftUI

public extension View {
    /// Present an `ARCPaywallView` as a sheet.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls sheet presentation.
    ///   - configuration: Paywall content configuration.
    ///   - theme: Visual theme. Defaults to `PaywallTheme.default`.
    ///   - onPurchaseCompleted: Called when a purchase attempt resolves or entitlements are
    ///     restored, carrying the `PurchaseResult`. The sheet auto-dismisses only on a
    ///     completed outcome (success or restore).
    func presentARCPaywall(isPresented: Binding<Bool>,
                           configuration: PaywallConfiguration,
                           theme: PaywallTheme = .default,
                           onPurchaseCompleted: (@Sendable (PurchaseResult) -> Void)? = nil) -> some View {
        sheet(isPresented: isPresented) {
            ARCPaywallView(configuration: configuration,
                           theme: theme,
                           onDismiss: { isPresented.wrappedValue = false },
                           onPurchaseCompleted: { result in
                               if result.isCompleted {
                                   isPresented.wrappedValue = false
                               }
                               onPurchaseCompleted?(result)
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
    ///   - configuration: Paywall content configuration.
    ///   - theme: Visual theme. Defaults to `PaywallTheme.default`.
    ///   - onPurchaseCompleted: Called when a purchase attempt resolves or entitlements are
    ///     restored, carrying the `PurchaseResult`.
    func presentARCPaywallIfNeeded(entitlement: String,
                                   configuration: PaywallConfiguration,
                                   theme: PaywallTheme = .default,
                                   onPurchaseCompleted: (@Sendable (PurchaseResult) -> Void)? = nil) -> some View {
        modifier(PaywallIfNeededModifier(entitlement: entitlement,
                                         configuration: configuration,
                                         theme: theme,
                                         onPurchaseCompleted: onPurchaseCompleted))
    }
}

// MARK: - PaywallIfNeededModifier

private struct PaywallIfNeededModifier: ViewModifier {
    let entitlement: String
    let configuration: PaywallConfiguration
    let theme: PaywallTheme
    let onPurchaseCompleted: (@Sendable (PurchaseResult) -> Void)?

    @State private var isPresented = false
    @State private var purchaseManager = ARCPurchaseManager.shared

    func body(content: Content) -> some View {
        content
            .presentARCPaywall(isPresented: $isPresented,
                               configuration: configuration,
                               theme: theme,
                               onPurchaseCompleted: onPurchaseCompleted)
            .task {
                guard purchaseManager.isConfigured else { return }
                let hasEntitlement = await purchaseManager.hasEntitlement(entitlement)
                if !hasEntitlement {
                    isPresented = true
                }
            }
    }
}
