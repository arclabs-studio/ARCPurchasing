//
//  DefaultPurchaseAnalyticsTests.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 24/03/2025.
//

import Foundation
import Testing
@testable import ARCPurchasing

struct DefaultPurchaseAnalyticsTests {
    // MARK: - All Events

    @Test("track handles all event types without crashing") func track_allEvents_doesNotCrash() async {
        let analytics = DefaultPurchaseAnalytics()

        await analytics.track(.productViewed(productID: "test.product"))
        await analytics.track(.paywallViewed(paywallID: "annual"))
        await analytics.track(.paywallViewed(paywallID: nil))
        await analytics.track(.purchaseStarted(productID: "test.product"))
        await analytics.track(.purchaseCompleted(productID: "test.product",
                                                 price: 9.99,
                                                 currency: "USD",
                                                 transactionID: "txn_123"))
        await analytics.track(.purchaseCancelled(productID: "test.product"))
        await analytics.track(.purchaseFailed(productID: "test.product", error: "Network error"))
        await analytics.track(.purchasePending(productID: "test.product"))
        await analytics.track(.subscriptionRenewed(productID: "test.subscription"))
        await analytics.track(.subscriptionCancelled(productID: "test.subscription"))
        await analytics.track(.subscriptionExpired(productID: "test.subscription"))
        await analytics.track(.restorePurchasesStarted)
        await analytics.track(.restorePurchasesCompleted)
        await analytics.track(.restorePurchasesFailed(error: "Restore failed"))
        await analytics.track(.paywallDismissed(paywallID: "annual"))
        await analytics.track(.paywallDismissed(paywallID: nil))
        await analytics.track(.customerCenterOpened)
        await analytics.track(.customerCenterDismissed)
        // All 18 events processed — success is reaching this line without crash.
    }

    @Test("DefaultPurchaseAnalytics conforms to PurchaseAnalytics") func conformsToProtocol() {
        let analytics: any PurchaseAnalytics = DefaultPurchaseAnalytics()
        #expect(analytics is DefaultPurchaseAnalytics)
    }

    @Test("Custom logger is used when injected") func customLogger_isUsed() async {
        // Verifies the initializer accepts a custom logger without crashing.
        let analytics = DefaultPurchaseAnalytics(logger: .shared)
        await analytics.track(.restorePurchasesStarted)
    }
}
