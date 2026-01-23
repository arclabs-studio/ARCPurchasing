//
//  PaywallView.swift
//  ARCPurchasingDemoApp
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCPurchasing
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = ARCPurchaseManager.shared
    @State private var products: [PurchaseProduct] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var purchaseResult: PurchaseResult?

    // Replace with your actual product IDs from App Store Connect
    private let productIDs: Set<String> = [
        "com.arclabs.demo.premium.monthly",
        "com.arclabs.demo.premium.yearly"
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if products.isEmpty {
                    emptyView
                } else {
                    productListView
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadProducts()
        }
        .alert(
            "Purchase Result",
            isPresented: .constant(purchaseResult != nil)
        ) {
            Button("OK") {
                purchaseResult = nil
                if purchaseResult?.isSuccess == true {
                    dismiss()
                }
            }
        } message: {
            Text(purchaseResultMessage)
        }
    }

    // MARK: - Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading products...")
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task {
                    await loadProducts()
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Products", systemImage: "cart")
        } description: {
            Text("No products available for purchase.")
        } actions: {
            Button("Retry") {
                Task {
                    await loadProducts()
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var productListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)

                    Text("Unlock Premium")
                        .font(.title.bold())

                    Text("Get access to all features")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited access")
                    FeatureRow(icon: "checkmark.circle.fill", text: "No ads")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Priority support")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Exclusive content")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Products
                VStack(spacing: 12) {
                    ForEach(products) { product in
                        ProductCard(
                            product: product,
                            isPurchasing: purchaseManager.isPurchasing,
                            onPurchase: {
                                Task {
                                    await purchase(product)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Footer
                VStack(spacing: 8) {
                    Button("Restore Purchases") {
                        Task {
                            await restorePurchases()
                        }
                    }
                    .font(.footnote)
                    .disabled(purchaseManager.isRestoring)

                    Text("Payment will be charged to your Apple ID account.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }

    // MARK: - Purchase Result Message

    private var purchaseResultMessage: String {
        guard let result = purchaseResult else { return "" }

        switch result {
        case .success:
            return "Thank you for your purchase!"
        case .cancelled:
            return "Purchase was cancelled."
        case .pending:
            return "Your purchase is pending approval."
        case let .requiresAction(action):
            return "Action required: \(action)"
        case .unknown:
            return "An unknown error occurred."
        }
    }

    // MARK: - Actions

    private func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await purchaseManager.fetchProducts(for: productIDs)
            // Sort by price (cheapest first)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func purchase(_ product: PurchaseProduct) async {
        do {
            purchaseResult = try await purchaseManager.purchase(product)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restorePurchases() async {
        do {
            try await purchaseManager.restorePurchases()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
            Spacer()
        }
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: PurchaseProduct
    let isPurchasing: Bool
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)

                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let period = product.subscriptionPeriod {
                        Text(period.displayDescription)
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.title2.bold())

                    if let period = product.subscriptionPeriod {
                        Text("per \(period.unit.shortName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                onPurchase()
            } label: {
                if isPurchasing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Subscribe")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isPurchasing)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - SubscriptionPeriod Extension

extension SubscriptionPeriod {
    var displayDescription: String {
        if value == 1 {
            "\(unit.name) subscription"
        } else {
            "\(value) \(unit.name)s subscription"
        }
    }
}

extension PeriodUnit {
    var name: String {
        switch self {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        }
    }

    var shortName: String {
        switch self {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        }
    }
}

#Preview {
    PaywallView()
}
