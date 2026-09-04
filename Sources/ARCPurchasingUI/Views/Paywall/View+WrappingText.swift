//
//  View+WrappingText.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import SwiftUI

extension View {
    /// Lets text grow to as many lines as it needs instead of truncating.
    ///
    /// Applied to every label the paywall must keep readable — prices above all — so large
    /// Dynamic Type sizes wrap rather than turning into an ellipsis.
    func wrappingText() -> some View {
        lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}
