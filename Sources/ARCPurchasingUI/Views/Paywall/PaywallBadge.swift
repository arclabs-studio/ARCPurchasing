//
//  PaywallBadge.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import Foundation

/// The badge shown on a subscription card.
///
/// Auto-calculated savings are our copy and localize through the app's catalog; badges
/// coming from `PaywallConfiguration.badgeOverrides` are the app's own already-localized
/// strings and pass through verbatim.
enum PaywallBadge {
    /// Auto-calculated savings against the monthly baseline, in whole percent.
    case savings(Int)

    /// An app-supplied badge from `PaywallConfiguration.badgeOverrides`.
    case custom(String)

    /// The badge copy, tagged by origin.
    var copy: PaywallCopy {
        switch self {
        case let .savings(percentage): .localized(LocalizedStringResource("SAVE \(percentage)%"))
        case let .custom(value): .verbatim(value)
        }
    }
}
