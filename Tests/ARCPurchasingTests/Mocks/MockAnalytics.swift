//
//  MockAnalytics.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
@testable import ARCPurchasing

/// Mock implementation of ``PurchaseAnalytics`` for testing.
final class MockAnalytics: PurchaseAnalytics, @unchecked Sendable {
    // MARK: - Call Tracking

    private(set) var trackedEvents: [PurchaseEvent] = []
    var trackCalled: Bool { !trackedEvents.isEmpty }

    // MARK: - PurchaseAnalytics

    func track(_ event: PurchaseEvent) async {
        trackedEvents.append(event)
    }

    // MARK: - Helpers

    /// Reset tracked events.
    func reset() {
        trackedEvents = []
    }

    /// Check if a specific event type was tracked.
    func hasTracked(eventNamed name: String) -> Bool {
        trackedEvents.contains { $0.name == name }
    }

    /// Get all events for a specific product ID.
    func events(forProductID productID: String) -> [PurchaseEvent] {
        trackedEvents.filter { $0.productID == productID }
    }
}
