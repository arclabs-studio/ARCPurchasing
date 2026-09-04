//
//  PurchaseProduct+PaywallCopy.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import ARCPurchasing
import Foundation

extension PurchaseProduct {
    /// The card's period line — "MONTHLY", "YEARLY", "6 MONTHS"…
    ///
    /// Products without a subscription period fall back to their store display name,
    /// which is runtime data and therefore verbatim.
    var paywallPeriodCopy: PaywallCopy {
        guard let period = subscriptionPeriod else {
            return .verbatim(displayName.uppercased())
        }
        switch (period.value, period.unit) {
        case (1, .month): return .localized(LocalizedStringResource("MONTHLY"))
        case (1, .year), (12, .month): return .localized(LocalizedStringResource("YEARLY"))
        case (3, .month): return .localized(LocalizedStringResource("QUARTERLY"))
        case (6, .month): return .localized(LocalizedStringResource("6 MONTHS"))
        default: return .localized(period.unitCountResource)
        }
    }

    /// The card's bottom line: "per month" for monthly plans, the monthly equivalent
    /// otherwise, and nothing at all for products without a subscription period.
    var paywallBottomCopy: PaywallCopy? {
        guard let period = subscriptionPeriod else { return nil }
        let totalMonths = period.totalMonths
        guard totalMonths > 1 else { return .localized(LocalizedStringResource("per month")) }
        let equivalent = price / Decimal(totalMonths)
        let formatted = equivalent.formatted(.currency(code: currencyCode).precision(.fractionLength(2)))
        // The price is an argument, not a fragment to concatenate — no other language
        // composes this phrase the way English does.
        return .localized(LocalizedStringResource("\(formatted)/month"))
    }
}

// MARK: - Period Vocabulary

private extension SubscriptionPeriod {
    /// Singular and plural keys per unit, kept explicit so the plural "S" is never glued
    /// onto a raw enum value the way English — and only English — allows.
    var unitCountResource: LocalizedStringResource {
        if value == 1 {
            switch unit {
            case .day: return LocalizedStringResource("DAY")
            case .week: return LocalizedStringResource("WEEK")
            case .month: return LocalizedStringResource("MONTH")
            case .year: return LocalizedStringResource("YEAR")
            }
        }
        switch unit {
        case .day: return LocalizedStringResource("\(value) DAYS")
        case .week: return LocalizedStringResource("\(value) WEEKS")
        case .month: return LocalizedStringResource("\(value) MONTHS")
        case .year: return LocalizedStringResource("\(value) YEARS")
        }
    }
}
