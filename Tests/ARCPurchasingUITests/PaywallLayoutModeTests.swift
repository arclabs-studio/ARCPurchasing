//
//  PaywallLayoutModeTests.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import SwiftUI
import Testing
@testable import ARCPurchasingUI

/// Verifies the paywall layout policy: which Dynamic Type sizes dissolve the pinned
/// bottom block into a single scrolling column.
///
/// The expectation table is written out literally on purpose — deriving it from
/// `DynamicTypeSize.isAccessibilitySize` would restate the implementation instead of
/// checking it.
struct PaywallLayoutModeTests {
    // MARK: - Oracle

    static let expectations: [(DynamicTypeSize, PaywallLayoutMode)] = [(.xSmall, .pinned),
                                                                       (.small, .pinned),
                                                                       (.medium, .pinned),
                                                                       (.large, .pinned),
                                                                       (.xLarge, .pinned),
                                                                       (.xxLarge, .pinned),
                                                                       (.xxxLarge, .pinned),
                                                                       (.accessibility1, .scrolling),
                                                                       (.accessibility2, .scrolling),
                                                                       (.accessibility3, .scrolling),
                                                                       (.accessibility4, .scrolling),
                                                                       (.accessibility5, .scrolling)]

    // MARK: - Tests

    @Test("Layout mode matches the expected mode for every Dynamic Type size",
          arguments: PaywallLayoutModeTests.expectations)
    func layoutMode(size: DynamicTypeSize, expected: PaywallLayoutMode) {
        // Given a Dynamic Type size / When the layout mode is derived
        let mode = PaywallLayoutMode(dynamicTypeSize: size)

        // Then it matches the expected mode
        #expect(mode == expected, "\(size) should use \(expected), got \(mode)")
    }

    @Test("Every Dynamic Type size the platform reports is classified") func expectations_coverEveryDynamicTypeSize() {
        // Given the literal expectation table / When compared against the platform's sizes
        let covered = Set(Self.expectations.map(\.0))

        // Then no size is left to the implementation's fallback
        #expect(covered == Set(DynamicTypeSize.allCases))
    }
}
