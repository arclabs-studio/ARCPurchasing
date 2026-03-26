//
//  ARCPaywallView.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import ARCPurchasing
import SwiftUI

/// A fully custom, configurable paywall view.
///
/// `ARCPaywallView` fetches products from `ARCPurchaseManager`, renders a
/// branded paywall based on the provided `PaywallConfiguration` and
/// `PaywallTheme`, and handles the full purchase and restore flow including
/// analytics tracking.
///
/// ## Usage
///
/// ```swift
/// ARCPaywallView(
///     configuration: PaywallConfiguration(
///         headerLabel: "FORKS PREMIUM",
///         title: "Unlock the full\nForks experience",
///         subtitle: "Your food journey, without limits",
///         iconName: "fork.knife",
///         features: [
///             .init(highlightedText: "Year in Food",
///                   description: "— full annual stats & insights"),
///             .init(highlightedText: "AI recommendations",
///                   description: "tailored to your taste"),
///         ],
///         highlightedProductID: "com.app.yearly",
///         lifetimeProductID: "com.app.lifetime",
///         lifetimeSubtitle: "One-time purchase · Limited offer",
///         ctaButtonTitle: "Start Premium",
///         termsOfServiceURL: tosURL,
///         privacyPolicyURL: privacyURL
///     ),
///     theme: .darkBurgundy,
///     onDismiss: { dismiss() }
/// )
/// ```
public struct ARCPaywallView: View {
    // MARK: - Properties

    private let configuration: PaywallConfiguration
    private let theme: PaywallTheme
    private let previewProducts: [PurchaseProduct]?
    private let onDismiss: (() -> Void)?
    private let onPurchaseCompleted: (() -> Void)?

    @State private var purchaseManager = ARCPurchaseManager.shared

    // Products
    @State private var subscriptionProducts: [PurchaseProduct] = []
    @State private var lifetimeProduct: PurchaseProduct?
    @State private var selectedProductID: String?

    // Loading state
    @State private var loadingState: LoadingState = .loading
    @State private var purchaseError: String?

    // MARK: - Initialization

    /// Creates a paywall view.
    ///
    /// - Parameters:
    ///   - configuration: Content configuration (copy, features, product IDs, URLs).
    ///   - theme: Visual theme. Defaults to `PaywallTheme.default` (dark burgundy).
    ///   - previewProducts: Optional mock products used instead of fetching from RevenueCat.
    ///     Pass products created with the public `PurchaseProduct` initializer to render the
    ///     paywall without a network connection — useful for Xcode Previews and demo apps.
    ///     Products provided here cannot be purchased (they have no underlying StoreProduct).
    ///   - onDismiss: Called when the user dismisses without purchasing.
    ///   - onPurchaseCompleted: Called after a successful purchase or restore.
    public init(configuration: PaywallConfiguration,
                theme: PaywallTheme = .default,
                previewProducts: [PurchaseProduct]? = nil,
                onDismiss: (() -> Void)? = nil,
                onPurchaseCompleted: (() -> Void)? = nil) {
        self.configuration = configuration
        self.theme = theme
        self.previewProducts = previewProducts
        self.onDismiss = onDismiss
        self.onPurchaseCompleted = onPurchaseCompleted
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            switch loadingState {
            case .loading:
                loadingView
            case let .error(message):
                errorView(message)
            case .loaded:
                paywallContent
            }
        }
        .task {
            await purchaseManager.track(.paywallViewed(paywallID: configuration.offeringIdentifier))
            await loadProducts()
        }
        .alert("Purchase Error", isPresented: Binding(get: { purchaseError != nil },
                                                      set: { if !$0 { purchaseError = nil } })) {
            Button("OK") { purchaseError = nil }
        } message: {
            Text(purchaseError ?? "")
        }
    }

    // MARK: - Loading / Error Views

    private var loadingView: some View {
        ProgressView()
            .tint(theme.accentColor)
            .scaleEffect(1.5)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn't Load Products", systemImage: "exclamationmark.triangle")
                .foregroundStyle(theme.primaryTextColor)
        } description: {
            Text(message)
                .foregroundStyle(theme.secondaryTextColor)
        } actions: {
            Button("Retry") {
                Task { await loadProducts() }
            }
            .buttonStyle(.bordered)
            .tint(theme.accentColor)
        }
    }

    // MARK: - Paywall Content

    private var paywallContent: some View {
        VStack(spacing: 20) {
            PaywallHeaderView(configuration: configuration,
                              theme: theme)

            if !configuration.features.isEmpty {
                PaywallFeatureListView(features: configuration.features,
                                       theme: theme)
            }

            Spacer(minLength: 0)

            // Products
            VStack(spacing: 10) {
                if !subscriptionProducts.isEmpty {
                    PaywallSubscriptionCardsView(products: subscriptionProducts,
                                                 selectedProductID: selectedProductID,
                                                 highlightedProductID: configuration.highlightedProductID,
                                                 badges: computedBadges,
                                                 theme: theme,
                                                 onSelect: { selectedProductID = $0.id })
                }

                if let lifetime = lifetimeProduct {
                    PaywallLifetimeCardView(product: lifetime,
                                            subtitle: configuration.lifetimeSubtitle,
                                            isSelected: selectedProductID == lifetime.id,
                                            theme: theme,
                                            onTap: { selectedProductID = lifetime.id })
                }
            }
            .padding(.horizontal, 24)

            PaywallContinueButton(title: configuration.ctaButtonTitle,
                                  isLoading: purchaseManager.isPurchasing,
                                  isDisabled: selectedProductID == nil,
                                  theme: theme,
                                  action: { Task { await purchase() } })

            PaywallFooterView(renewalDisclosure: configuration.renewalDisclosure,
                              termsOfServiceURL: configuration.termsOfServiceURL,
                              privacyPolicyURL: configuration.privacyPolicyURL,
                              theme: theme,
                              onRestore: { Task { await restore() } },
                              isRestoring: purchaseManager.isRestoring)
        }
        .padding(.bottom, 8)
        #if os(iOS)
            .overlay(alignment: .topTrailing) {
                dismissButton
            }
        #endif
    }

    #if os(iOS)
    private var dismissButton: some View {
        Button {
            Task {
                await purchaseManager.track(.paywallDismissed(paywallID: configuration.offeringIdentifier))
            }
            onDismiss?()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(theme.accentColor)
                // Explicit 44×44 touch target per HIG
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        // 16pt inset from top and trailing edges per HIG spacing guidelines
        .padding(.top, 16)
        .padding(.trailing, 16)
    }
    #endif
}

// MARK: - Private Helpers

private extension ARCPaywallView {
    // MARK: Product Loading

    func loadProducts() async {
        loadingState = .loading

        do {
            // Use preview products if injected (bypasses network — for demos and Xcode Previews)
            let targetProducts: [PurchaseProduct]
            if let preview = previewProducts {
                targetProducts = preview
            } else {
                let offerings = try await purchaseManager.fetchOfferings()

                // Pick the target offering or fall back to the first available
                if let id = configuration.offeringIdentifier,
                   let products = offerings[id] {
                    targetProducts = products
                } else {
                    targetProducts = offerings.values.first ?? []
                }
            }

            guard !targetProducts.isEmpty else {
                loadingState = .error("No products available. Please try again later.")
                return
            }

            // Separate lifetime from subscriptions
            let lifetime = configuration.lifetimeProductID.flatMap { id in
                targetProducts.first { $0.id == id }
            }
            let subscriptions = targetProducts
                .filter { $0.id != configuration.lifetimeProductID }
                .filter { $0.type == .autoRenewableSubscription || $0.type == .nonRenewableSubscription }
                .sorted { $0.price < $1.price }

            lifetimeProduct = lifetime
            subscriptionProducts = subscriptions

            // Auto-select highlighted product or default to first subscription
            if let highlightedID = configuration.highlightedProductID,
               targetProducts.contains(where: { $0.id == highlightedID }) {
                selectedProductID = highlightedID
            } else {
                selectedProductID = subscriptions.first?.id ?? lifetime?.id
            }

            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: Purchase

    func purchase() async {
        guard let selectedID = selectedProductID else { return }

        let allProducts = subscriptionProducts + (lifetimeProduct.map { [$0] } ?? [])
        guard let product = allProducts.first(where: { $0.id == selectedID }) else { return }

        do {
            let result = try await purchaseManager.purchase(product)
            switch result {
            case .success:
                await purchaseManager.refreshState()
                onPurchaseCompleted?()
            case .cancelled, .pending:
                break
            case let .requiresAction(message):
                purchaseError = message
            case .unknown:
                purchaseError = "An unknown error occurred. Please try again."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: Restore

    func restore() async {
        do {
            try await purchaseManager.restorePurchases()
            onPurchaseCompleted?()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: Badge Calculation

    /// Merges auto-calculated savings badges with `badgeOverrides`.
    /// Manual overrides always take precedence.
    var computedBadges: [String: String] {
        guard configuration.autoCalculateSavings else {
            return configuration.badgeOverrides
        }

        var badges = savingsBadges(for: subscriptionProducts)
        for (id, badge) in configuration.badgeOverrides {
            badges[id] = badge
        }
        return badges
    }

    /// Calculates "SAVE X%" badges for subscriptions with >1-month periods,
    /// using the monthly product as the baseline.
    func savingsBadges(for products: [PurchaseProduct]) -> [String: String] {
        guard products.count > 1 else { return [:] }

        // Find the monthly baseline product
        let monthly = products.first {
            $0.subscriptionPeriod?.unit == .month && $0.subscriptionPeriod?.value == 1
        }
        guard let monthlyPrice = monthly?.price, monthlyPrice > 0 else { return [:] }

        var badges: [String: String] = [:]
        for product in products {
            guard product.id != monthly?.id,
                  let period = product.subscriptionPeriod else { continue }
            let totalMonths = period.totalMonths
            guard totalMonths > 1, product.price > 0 else { continue }

            let monthlyEquivalent = product.price / Decimal(totalMonths)
            let savings = (1 - monthlyEquivalent / monthlyPrice) * 100
            let savingsInt = Int((savings as NSDecimalNumber).doubleValue.rounded())
            if savingsInt > 0 {
                badges[product.id] = "SAVE \(savingsInt)%"
            }
        }
        return badges
    }
}

// MARK: - LoadingState

private enum LoadingState {
    case loading
    case loaded
    case error(String)
}

// MARK: - Preview Helpers

public extension ARCPaywallView {
    // swiftlint:disable line_length
    /// Mock products for use in Xcode Previews and the demo app.
    ///
    /// These products have no underlying StoreProduct and cannot be purchased,
    /// but they render the full paywall UI correctly for visual verification.
    static let previewMockProducts: [PurchaseProduct] = [PurchaseProduct(id: "com.app.premium.monthly",
                                                                         displayName: "Monthly",
                                                                         description: "Monthly subscription",
                                                                         price: 4.99,
                                                                         displayPrice: "$4.99",
                                                                         currencyCode: "USD",
                                                                         type: .autoRenewableSubscription,
                                                                         subscriptionPeriod: SubscriptionPeriod(value: 1,
                                                                                                                unit: .month)),
                                                         PurchaseProduct(id: "com.app.premium.yearly",
                                                                         displayName: "Yearly",
                                                                         description: "Yearly subscription",
                                                                         price: 34.99,
                                                                         displayPrice: "$34.99",
                                                                         currencyCode: "USD",
                                                                         type: .autoRenewableSubscription,
                                                                         subscriptionPeriod: SubscriptionPeriod(value: 1,
                                                                                                                unit: .year)),
                                                         PurchaseProduct(id: "com.app.premium.lifetime",
                                                                         displayName: "Lifetime Access",
                                                                         description: "One-time purchase",
                                                                         price: 89.99,
                                                                         displayPrice: "$89.99",
                                                                         currencyCode: "USD",
                                                                         type: .nonConsumable)]
    // swiftlint:enable line_length
}

// MARK: - Previews

// swiftlint:disable force_unwrapping
private let _previewConfig = PaywallConfiguration(headerLabel: "FORKS PREMIUM",
                                                  title: "Unlock the full\nForks experience",
                                                  subtitle: "Your food journey, without limits",
                                                  iconName: "fork.knife",
                                                  features: [.init(highlightedText: "Year in Food",
                                                                   description: "— full annual stats & insights"),
                                                             .init(highlightedText: "AI recommendations",
                                                                   description: "tailored to your taste"),
                                                             .init(highlightedText: "Export & share",
                                                                   description: "your lists anywhere"),
                                                             .init(highlightedText: "Visual themes",
                                                                   description: "to personalize your profile")],
                                                  highlightedProductID: "com.app.premium.yearly",
                                                  lifetimeProductID: "com.app.premium.lifetime",
                                                  lifetimeSubtitle: "One-time purchase · Limited offer",
                                                  ctaButtonTitle: "Start Premium",
                                                  termsOfServiceURL: URL(string: "https://example.com/terms")!,
                                                  privacyPolicyURL: URL(string: "https://example.com/privacy")!)
// swiftlint:enable force_unwrapping

#Preview("Dark — Burgundy") {
    ARCPaywallView(configuration: _previewConfig,
                   theme: .darkBurgundy,
                   previewProducts: ARCPaywallView.previewMockProducts)
}

#Preview("Light — Gold") {
    ARCPaywallView(configuration: _previewConfig,
                   theme: .lightGold,
                   previewProducts: ARCPaywallView.previewMockProducts)
}

// swiftlint:disable force_unwrapping line_length
private let _previewConfigNoLifetime = PaywallConfiguration(headerLabel: "FORKS PREMIUM",
                                                            title: "Unlock the full\nForks experience",
                                                            subtitle: "Your food journey, without limits",
                                                            iconName: "fork.knife",
                                                            features: [.init(highlightedText: "Year in Food",
                                                                             description: "— full annual stats & insights"),
                                                                       .init(highlightedText: "AI recommendations",
                                                                             description: "tailored to your taste")],
                                                            highlightedProductID: "com.app.premium.yearly",
                                                            ctaButtonTitle: "Start Premium",
                                                            termsOfServiceURL: URL(string: "https://example.com/terms")!,
                                                            privacyPolicyURL: URL(string: "https://example.com/privacy")!)
// swiftlint:enable force_unwrapping line_length

#Preview("Dark — No Lifetime") {
    ARCPaywallView(configuration: _previewConfigNoLifetime,
                   theme: .darkBurgundy,
                   previewProducts: Array(ARCPaywallView.previewMockProducts.prefix(2)))
}
