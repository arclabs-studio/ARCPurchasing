//
//  MockAnalytics.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import Foundation
import os
@testable import ARCPurchasing

/// Mock implementation of ``PurchaseAnalytics`` for testing.
final class MockAnalytics: PurchaseAnalytics {
    private struct State {
        var trackedEvents: [PurchaseEvent] = []
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Call Tracking

    var trackedEvents: [PurchaseEvent] {
        state.withLock { $0.trackedEvents }
    }

    var trackCalled: Bool {
        !trackedEvents.isEmpty
    }

    // MARK: - PurchaseAnalytics

    func track(_ event: PurchaseEvent) async {
        state.withLock { $0.trackedEvents.append(event) }
    }

    // MARK: - Helpers

    /// Reset tracked events.
    func reset() {
        state.withLock { $0.trackedEvents = [] }
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
