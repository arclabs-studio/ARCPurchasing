//
//  PurchaseEventTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Testing
@testable import ARCPurchasing

struct PurchaseEventTests {
    // MARK: - Event Name Tests

    @Test("All events have correct names") func name_returnsCorrectValue() {
        #expect(PurchaseEvent.productViewed(productID: "x").name == "product_viewed")
        #expect(PurchaseEvent.paywallViewed(paywallID: nil).name == "paywall_viewed")
        #expect(PurchaseEvent.purchaseStarted(productID: "x").name == "purchase_started")
        #expect(PurchaseEvent.purchaseCompleted(productID: "x", price: 9.99, currency: "USD", transactionID: "t")
            .name == "purchase_completed")
        #expect(PurchaseEvent.purchaseCancelled(productID: "x").name == "purchase_cancelled")
        #expect(PurchaseEvent.purchaseFailed(productID: "x", error: "e").name == "purchase_failed")
        #expect(PurchaseEvent.purchasePending(productID: "x").name == "purchase_pending")
        #expect(PurchaseEvent.subscriptionRenewed(productID: "x").name == "subscription_renewed")
        #expect(PurchaseEvent.subscriptionCancelled(productID: "x").name == "subscription_cancelled")
        #expect(PurchaseEvent.subscriptionExpired(productID: "x").name == "subscription_expired")
        #expect(PurchaseEvent.restorePurchasesStarted.name == "restore_purchases_started")
        #expect(PurchaseEvent.restorePurchasesCompleted.name == "restore_purchases_completed")
        #expect(PurchaseEvent.restorePurchasesFailed(error: "e").name == "restore_purchases_failed")
        // UI events
        #expect(PurchaseEvent.paywallDismissed(paywallID: nil).name == "paywall_dismissed")
        #expect(PurchaseEvent.customerCenterOpened.name == "customer_center_opened")
        #expect(PurchaseEvent.customerCenterDismissed.name == "customer_center_dismissed")
    }

    // MARK: - Product ID Tests

    @Test("Product events return correct productID") func productID_returnsCorrectValue() {
        let id = "com.test.premium"
        #expect(PurchaseEvent.productViewed(productID: id).productID == id)
        #expect(PurchaseEvent.purchaseStarted(productID: id).productID == id)
        #expect(PurchaseEvent.purchaseCompleted(productID: id, price: 9.99, currency: "USD", transactionID: "t")
            .productID == id)
        #expect(PurchaseEvent.purchaseCancelled(productID: id).productID == id)
        #expect(PurchaseEvent.purchaseFailed(productID: id, error: "e").productID == id)
        #expect(PurchaseEvent.purchasePending(productID: id).productID == id)
        #expect(PurchaseEvent.subscriptionRenewed(productID: id).productID == id)
        #expect(PurchaseEvent.subscriptionCancelled(productID: id).productID == id)
        #expect(PurchaseEvent.subscriptionExpired(productID: id).productID == id)
    }

    @Test("Non-product events return nil productID") func productID_returnsNilForNonProductEvents() {
        #expect(PurchaseEvent.paywallViewed(paywallID: "pw").productID == nil)
        #expect(PurchaseEvent.restorePurchasesStarted.productID == nil)
        #expect(PurchaseEvent.restorePurchasesCompleted.productID == nil)
        #expect(PurchaseEvent.restorePurchasesFailed(error: "e").productID == nil)
        #expect(PurchaseEvent.paywallDismissed(paywallID: "pw").productID == nil)
        #expect(PurchaseEvent.customerCenterOpened.productID == nil)
        #expect(PurchaseEvent.customerCenterDismissed.productID == nil)
    }
}
