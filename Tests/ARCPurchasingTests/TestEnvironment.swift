//
//  TestEnvironment.swift
//  ARCPurchasingTests
//
//  Created by ARC Labs Studio on 13/05/2026.
//

import Foundation
import Testing

/// Test environment flags read from `ProcessInfo`.
enum TestEnvironment {
    /// Set `ARCP_RUN_SK2_INTEGRATION=1` to run smoke tests that exercise the
    /// real StoreKit 2 stack. These tests require a hosting bundle and are
    /// skipped under `swift test` (and on CI) because `Transaction.updates`
    /// and `Transaction.currentEntitlements` hang when no host bundle is
    /// available. The same flows are covered end-to-end in `Example/`.
    static var runsStoreKitIntegrationTests: Bool {
        ProcessInfo.processInfo.environment["ARCP_RUN_SK2_INTEGRATION"] == "1"
    }
}

extension Trait where Self == ConditionTrait {
    /// Skips the test unless the host environment can run StoreKit 2.
    static var requiresStoreKitHost: ConditionTrait {
        .enabled(if: TestEnvironment.runsStoreKitIntegrationTests,
                 "Skipped: requires StoreKit hosting bundle. Set ARCP_RUN_SK2_INTEGRATION=1 to run.")
    }
}
