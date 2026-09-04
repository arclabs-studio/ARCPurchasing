//
//  PaywallLayoutMode.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import SwiftUI

/// Layout strategy used by ``ARCPaywallView``, derived from the environment's Dynamic Type size.
///
/// At standard content sizes the paywall keeps its conversion-optimised shape: the products,
/// the CTA and the footer stay pinned to the bottom while only the header and the feature list
/// scroll. At accessibility sizes that pinned block no longer fits, so the whole paywall becomes
/// a single scrolling column and the product cards stack vertically.
enum PaywallLayoutMode: Equatable {
    /// Products, CTA and footer pinned below a scrolling header — standard content sizes.
    case pinned
    /// Every section in a single scrolling column — accessibility content sizes.
    case scrolling

    /// Chooses the layout for a Dynamic Type size.
    ///
    /// - Parameter dynamicTypeSize: The size read from `\.dynamicTypeSize`.
    init(dynamicTypeSize: DynamicTypeSize) {
        switch dynamicTypeSize {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            self = .scrolling
        default:
            self = .pinned
        }
    }
}
