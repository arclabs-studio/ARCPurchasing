//
//  ContentView.swift
//  ARCPurchasingDemoApp
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import ARCPurchasing
import SwiftUI

struct ContentView: View {
    @State private var purchaseManager = ARCPurchaseManager.shared
    @State private var showPaywall = false

    private var demoInfoText: String {
        "This demo app shows how to integrate ARCPurchasing. " +
            "Replace the API key in the App file with your RevenueCat API key."
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Status Section

                Section("Subscription Status") {
                    HStack {
                        Text("Configured")
                        Spacer()
                        Image(systemName: purchaseManager.isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(purchaseManager.isConfigured ? .green : .red)
                    }

                    HStack {
                        Text("Subscribed")
                        Spacer()
                        Image(systemName: purchaseManager.isSubscribed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(purchaseManager.isSubscribed ? .green : .secondary)
                    }

                    if let status = purchaseManager.subscriptionStatus {
                        if let productID = status.activeProductID {
                            HStack {
                                Text("Active Product")
                                Spacer()
                                Text(productID)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let expiresDate = status.expiresDate {
                            HStack {
                                Text("Expires")
                                Spacer()
                                Text(expiresDate, style: .date)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        HStack {
                            Text("Will Renew")
                            Spacer()
                            Image(systemName: status.willRenew ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(status.willRenew ? .green : .secondary)
                        }
                    }
                }

                // MARK: - Entitlements Section

                Section("Active Entitlements") {
                    if purchaseManager.currentEntitlements.isEmpty {
                        Text("No active entitlements")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(purchaseManager.currentEntitlements) { entitlement in
                            EntitlementRow(entitlement: entitlement)
                        }
                    }
                }

                // MARK: - Actions Section

                Section("Actions") {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("View Paywall", systemImage: "creditcard")
                    }

                    Button {
                        Task {
                            await restorePurchases()
                        }
                    } label: {
                        if purchaseManager.isRestoring {
                            ProgressView()
                        } else {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(purchaseManager.isRestoring)

                    Button {
                        Task {
                            await purchaseManager.refreshState()
                        }
                    } label: {
                        Label("Refresh State", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                // MARK: - Demo Info Section

                Section {
                    Text(demoInfoText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Demo Info")
                }
            }
            .navigationTitle("ARCPurchasing Demo")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func restorePurchases() async {
        do {
            try await purchaseManager.restorePurchases()
        } catch {
            print("Restore failed: \(error)")
        }
    }
}

// MARK: - Entitlement Row

struct EntitlementRow: View {
    let entitlement: Entitlement

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entitlement.id)
                    .font(.headline)
                Spacer()
                if entitlement.isActive {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }

            if let productID = entitlement.productIdentifier {
                Text("Product: \(productID)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(entitlement.periodType.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())

                if entitlement.willRenew {
                    Text("Auto-renews")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EntitlementPeriodType Extension

extension EntitlementPeriodType {
    var displayName: String {
        switch self {
        case .normal:
            "Standard"
        case .trial:
            "Trial"
        case .intro:
            "Introductory"
        case .promotional:
            "Promotional"
        }
    }
}

#Preview {
    ContentView()
}
