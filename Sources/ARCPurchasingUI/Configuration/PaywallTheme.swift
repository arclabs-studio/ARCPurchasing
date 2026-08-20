//
//  PaywallTheme.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import SwiftUI

/// Visual theme for `ARCPaywallView`.
///
/// `PaywallTheme` controls all colours, corner radius, and the decorative
/// blob element. Two presets are provided (`darkBurgundy` and `lightGold`)
/// matching the reference designs. Custom themes can be built by constructing
/// the struct directly.
///
/// Because `Color` is not `Sendable` in Swift 6, `PaywallTheme` is
/// `@MainActor`-isolated — it is only used from SwiftUI views, so this
/// has no practical impact.
///
/// ## Usage
///
/// ```swift
/// // Use a preset
/// ARCPaywallView(configuration: config, theme: .darkBurgundy)
///
/// // Custom theme
/// ARCPaywallView(configuration: config, theme: PaywallTheme(
///     backgroundColor: .indigo,
///     ...
/// ))
/// ```
@MainActor
public struct PaywallTheme {
    // MARK: - Background

    /// Full-screen background fill.
    public let backgroundColor: Color

    /// Surface colour used for feature and product cards.
    public let cardBackgroundColor: Color

    /// Colour for the decorative blob in the top-right corner of the header.
    public let decorativeBlobColor: Color

    // MARK: - Text

    /// Colour for primary text: title, feature text body, product name/price.
    public let primaryTextColor: Color

    /// Colour for secondary text: subtitle, period labels, renewal disclosure.
    public let secondaryTextColor: Color

    /// Colour for accented text: header label, highlighted feature words.
    public let accentTextColor: Color

    // MARK: - Interactive

    /// Accent colour applied to: CTA button background, selected card border,
    /// badge background, and feature icon fill.
    public let accentColor: Color

    /// Text colour used on the CTA button.
    public let ctaTextColor: Color

    // MARK: - Cards

    /// Border colour for unselected product cards.
    public let cardBorderColor: Color

    /// Border colour for the currently selected product card.
    public let selectedCardBorderColor: Color

    /// Border colour (dashed) for the lifetime product card.
    public let lifetimeCardBorderColor: Color

    // MARK: - Layout

    /// Corner radius applied to cards and the CTA button. Default: `16`.
    public let cornerRadius: CGFloat

    // MARK: - Initialization

    /// Creates a paywall theme.
    public init(backgroundColor: Color,
                cardBackgroundColor: Color,
                decorativeBlobColor: Color,
                primaryTextColor: Color,
                secondaryTextColor: Color,
                accentTextColor: Color,
                accentColor: Color,
                ctaTextColor: Color,
                cardBorderColor: Color,
                selectedCardBorderColor: Color,
                lifetimeCardBorderColor: Color,
                cornerRadius: CGFloat = 16) {
        self.backgroundColor = backgroundColor
        self.cardBackgroundColor = cardBackgroundColor
        self.decorativeBlobColor = decorativeBlobColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.accentTextColor = accentTextColor
        self.accentColor = accentColor
        self.ctaTextColor = ctaTextColor
        self.cardBorderColor = cardBorderColor
        self.selectedCardBorderColor = selectedCardBorderColor
        self.lifetimeCardBorderColor = lifetimeCardBorderColor
        self.cornerRadius = cornerRadius
    }
}

// MARK: - Presets

public extension PaywallTheme {
    /// Dark burgundy theme — deep red background with gold accents.
    ///
    /// Matches the "DARK — BURGUNDY" variant from the reference designs.
    static let darkBurgundy = PaywallTheme(backgroundColor: Color(red: 0.329, green: 0.075, blue: 0.067), // #541311
                                           cardBackgroundColor: Color(red: 0.40, green: 0.11, blue: 0.09), // slightly
                                           // lighter burgundy
                                           decorativeBlobColor: Color(red: 0.45, green: 0.13, blue: 0.10), // subtle
                                           // blob
                                           primaryTextColor: .white,
                                           secondaryTextColor: Color(white: 0.70),
                                           accentTextColor: Color(red: 0.95, green: 0.70, blue: 0.20), // gold
                                           accentColor: Color(red: 0.95, green: 0.70, blue: 0.20), // gold
                                           ctaTextColor: Color(red: 0.25, green: 0.05, blue: 0.04), // dark text on gold
                                           // button
                                           cardBorderColor: Color(white: 1.0, opacity: 0.15),
                                           selectedCardBorderColor: Color(red: 0.95, green: 0.70, blue: 0.20),
                                           lifetimeCardBorderColor: Color(red: 0.95, green: 0.70, blue: 0.20,
                                                                          opacity: 0.6),
                                           cornerRadius: 16)

    /// Light gold theme — warm yellow background with dark burgundy accents.
    ///
    /// Matches the "LIGHT — GOLD" variant from the reference designs.
    static let lightGold = PaywallTheme(backgroundColor: Color(red: 0.95, green: 0.70, blue: 0.20), // gold
                                        cardBackgroundColor: Color(red: 1.0, green: 0.78, blue: 0.30, opacity: 0.50),
                                        decorativeBlobColor: Color(red: 1.0, green: 0.78, blue: 0.30, opacity: 0.60),
                                        primaryTextColor: Color(red: 0.25, green: 0.05, blue: 0.04), // dark burgundy
                                        secondaryTextColor: Color(red: 0.35, green: 0.10, blue: 0.08),
                                        accentTextColor: Color(red: 0.25, green: 0.05, blue: 0.04),
                                        accentColor: Color(red: 0.25, green: 0.05, blue: 0.04), // dark button on gold
                                        // bg
                                        ctaTextColor: Color(red: 0.95, green: 0.70, blue: 0.20), // gold text on dark
                                        // button
                                        cardBorderColor: Color(red: 0.25, green: 0.05, blue: 0.04, opacity: 0.20),
                                        selectedCardBorderColor: Color(red: 0.25, green: 0.05, blue: 0.04),
                                        lifetimeCardBorderColor: Color(red: 0.25, green: 0.05, blue: 0.04,
                                                                       opacity: 0.50),
                                        cornerRadius: 16)

    /// Default theme. Alias for `darkBurgundy`.
    static let `default` = PaywallTheme.darkBurgundy
}
