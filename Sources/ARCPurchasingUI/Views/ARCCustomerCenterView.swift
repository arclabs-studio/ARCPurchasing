//
//  ARCCustomerCenterView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

#if os(iOS)
import ARCPurchasing
import RevenueCatUI
import SwiftUI

/// A Customer Center view for subscription management, backed by RevenueCat.
///
/// `ARCCustomerCenterView` wraps RevenueCatUI's `CustomerCenterView`, automatically
/// refreshing `ARCPurchaseManager` state on dismissal and tracking analytics events.
///
/// Requires iOS 18.0 or later.
///
/// ## Usage
///
/// ```swift
/// struct ManageSubscriptionScreen: View {
///     @Environment(\.dismiss) private var dismiss
///
///     var body: some View {
///         ARCCustomerCenterView(onDismiss: { dismiss() })
///     }
/// }
/// ```
@available(iOS 18.0, *) public struct ARCCustomerCenterView: View {
    // MARK: - Properties

    private let onDismiss: (() -> Void)?

    @State private var purchaseManager = ARCPurchaseManager.shared

    // MARK: - Initialization

    /// Creates a Customer Center view.
    ///
    /// - Parameter onDismiss: Called when the view is dismissed.
    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        CustomerCenterView()
            .task {
                guard purchaseManager.isConfigured else { return }
                await purchaseManager.track(.customerCenterOpened)
            }
            .onDisappear {
                Task {
                    await purchaseManager.refreshState()
                    await purchaseManager.track(.customerCenterDismissed)
                }
                onDismiss?()
            }
    }
}
#endif
