//
//  PaywallCopy.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 04/09/2026.
//

import SwiftUI

/// A piece of paywall text, tagged with where it came from.
///
/// The package ships no string catalog on purpose: a `LocalizedStringResource` declared
/// here carries the *running app's* bundle, so the consuming app translates our keys from
/// its own `Localizable.xcstrings`. That only works through the localizing `Text`
/// initializer — a plain `String` reaches `Text(_ content: S) where S: StringProtocol`,
/// which no catalog entry can ever reach.
///
/// Runtime store data (`displayName`, `displayPrice`) and app-supplied copy are already
/// localized and must never be treated as keys, hence the explicit `verbatim` case.
enum PaywallCopy {
    /// Our own copy — a key the consuming app translates.
    case localized(LocalizedStringResource)

    /// Store or app-supplied copy — rendered exactly as given.
    case verbatim(String)

    /// The text view for this copy, through the matching `Text` initializer.
    var text: Text {
        switch self {
        case let .localized(resource): Text(resource)
        case let .verbatim(value): Text(verbatim: value)
        }
    }
}
