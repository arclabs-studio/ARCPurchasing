//
//  SubscriptionPeriod+Helpers.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import ARCPurchasing

extension SubscriptionPeriod {
    /// Approximate number of months in this period.
    var totalMonths: Int {
        switch unit {
        case .day: max(1, value / 30)
        case .week: max(1, value / 4)
        case .month: value
        case .year: value * 12
        }
    }
}
