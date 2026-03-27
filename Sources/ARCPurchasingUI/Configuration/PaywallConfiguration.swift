//
//  PaywallConfiguration.swift
//  ARCPurchasingUI
//
//  Created by ARC Labs Studio on 26/03/2025.
//

import Foundation

/// Content configuration for `ARCPaywallView`.
///
/// `PaywallConfiguration` defines everything an app needs to present
/// a branded paywall — header copy, feature list, product mapping,
/// CTA text, and legal links. Pass it alongside a `PaywallTheme` to
/// fully customise the paywall for each app.
///
/// ## Example
///
/// ```swift
/// let config = PaywallConfiguration(
///     headerLabel: "FORKS PREMIUM",
///     title: "Unlock the full\nForks experience",
///     subtitle: "Your food journey, without limits",
///     iconName: "fork.knife",
///     features: [
///         .init(highlightedText: "Year in Food",
///               description: "— full annual stats & insights"),
///         .init(highlightedText: "AI recommendations",
///               description: "tailored to your taste"),
///     ],
///     offeringIdentifier: "default",
///     highlightedProductID: "com.app.premium.yearly",
///     lifetimeProductID: "com.app.premium.lifetime",
///     ctaButtonTitle: "Start Premium",
///     termsOfServiceURL: tosURL,
///     privacyPolicyURL: privacyURL
/// )
/// ```
public struct PaywallConfiguration: Sendable {
    // MARK: - Header

    /// Uppercase label above the icon (e.g., "FORKS PREMIUM"). Pass `nil` to hide.
    public let headerLabel: String?

    /// Main title, supports newlines (e.g., `"Unlock the full\nForks experience"`).
    public let title: String

    /// Optional subtitle below the title.
    public let subtitle: String?

    /// SF Symbol name used as the paywall icon badge. Fallback when `iconAssetName` is nil.
    /// Rendered inside a coloured rounded-rectangle badge. Pass `nil` to hide the icon.
    public let iconName: String?

    /// Asset catalog image name used as the paywall icon. When set, renders the real app icon
    /// with rounded corners instead of the SF Symbol badge.
    public let iconAssetName: String?

    // MARK: - Features

    /// Ordered list of feature rows shown on the paywall.
    public let features: [Feature]

    // MARK: - Products

    /// RevenueCat offering identifier to fetch. `nil` uses the default current offering.
    public let offeringIdentifier: String?

    /// Product ID that is pre-selected and visually highlighted (accent border).
    /// Typically the yearly subscription. Pass `nil` to default to the first product.
    public let highlightedProductID: String?

    /// Product ID rendered as a separate full-width card with a dashed border.
    /// Use this for lifetime / non-consumable products.
    /// If `nil`, no lifetime card is shown and the product appears alongside subscriptions.
    public let lifetimeProductID: String?

    /// Subtitle shown on the lifetime card (e.g., `"One-time purchase · Limited offer"`).
    public let lifetimeSubtitle: String?

    // MARK: - CTA

    /// Text for the main purchase button (e.g., `"Start Premium"`).
    public let ctaButtonTitle: String

    /// Disclosure text shown above the footer links (e.g., `"Renews automatically. Cancel anytime."`).
    /// Pass `nil` to hide.
    public let renewalDisclosure: String?

    // MARK: - Legal

    /// URL opened when the user taps "Terms".
    public let termsOfServiceURL: URL

    /// URL opened when the user taps "Privacy".
    public let privacyPolicyURL: URL

    // MARK: - Badges

    /// Per-product badge overrides. Maps a product ID to a custom badge string
    /// (e.g., `["com.app.yearly": "BEST VALUE"]`).
    /// Takes precedence over auto-calculated savings badges.
    public let badgeOverrides: [String: String]

    /// When `true` (default), automatically calculates savings percentages
    /// for subscription products by comparing against the monthly baseline.
    /// e.g., yearly at $34.99 vs monthly at $4.99 → "SAVE 42%".
    public let autoCalculateSavings: Bool

    // MARK: - Initialization

    /// Creates a paywall configuration.
    ///
    /// - Parameters:
    ///   - headerLabel: Uppercase label above the icon. `nil` to hide.
    ///   - title: Main paywall title.
    ///   - subtitle: Optional subtitle below the title.
    ///   - iconName: SF Symbol name for the icon badge (ignored when `iconAssetName` is set).
    ///   - iconAssetName: Asset catalog image name. When set, renders the real app icon.
    ///   - features: Ordered list of feature rows.
    ///   - offeringIdentifier: RC offering identifier. `nil` uses the default.
    ///   - highlightedProductID: Product ID to pre-select and highlight.
    ///   - lifetimeProductID: Product ID rendered as a full-width dashed card.
    ///   - lifetimeSubtitle: Subtitle for the lifetime card.
    ///   - ctaButtonTitle: Text for the purchase CTA button.
    ///   - renewalDisclosure: Auto-renewal disclosure above the footer links.
    ///   - termsOfServiceURL: URL for the "Terms" link.
    ///   - privacyPolicyURL: URL for the "Privacy" link.
    ///   - badgeOverrides: Custom badge text per product ID.
    ///   - autoCalculateSavings: Whether to auto-calculate savings badges.
    public init(headerLabel: String? = nil,
                title: String,
                subtitle: String? = nil,
                iconName: String? = nil,
                iconAssetName: String? = nil,
                features: [Feature] = [],
                offeringIdentifier: String? = nil,
                highlightedProductID: String? = nil,
                lifetimeProductID: String? = nil,
                lifetimeSubtitle: String? = nil,
                ctaButtonTitle: String = "Continue",
                renewalDisclosure: String? = "Renews automatically. Cancel anytime.",
                termsOfServiceURL: URL,
                privacyPolicyURL: URL,
                badgeOverrides: [String: String] = [:],
                autoCalculateSavings: Bool = true) {
        self.headerLabel = headerLabel
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.iconAssetName = iconAssetName
        self.features = features
        self.offeringIdentifier = offeringIdentifier
        self.highlightedProductID = highlightedProductID
        self.lifetimeProductID = lifetimeProductID
        self.lifetimeSubtitle = lifetimeSubtitle
        self.ctaButtonTitle = ctaButtonTitle
        self.renewalDisclosure = renewalDisclosure
        self.termsOfServiceURL = termsOfServiceURL
        self.privacyPolicyURL = privacyPolicyURL
        self.badgeOverrides = badgeOverrides
        self.autoCalculateSavings = autoCalculateSavings
    }
}

// MARK: - Feature

public extension PaywallConfiguration {
    /// A single feature row on the paywall.
    ///
    /// Features render as: `[icon]  **highlightedText** description`
    ///
    /// ## Example
    /// ```swift
    /// Feature(highlightedText: "Year in Food",
    ///         description: "— full annual stats & insights")
    /// ```
    struct Feature: Sendable, Identifiable {
        /// Stable identifier (auto-generated if not provided).
        public let id: String

        /// Bold, accent-coloured prefix (e.g., `"Year in Food"`).
        public let highlightedText: String

        /// Regular-weight description following the highlighted text
        /// (e.g., `"— full annual stats & insights"`).
        public let description: String

        /// SF Symbol name for the row icon. Defaults to `"checkmark.circle.fill"`.
        public let iconName: String

        /// Creates a feature row.
        ///
        /// - Parameters:
        ///   - id: Stable identifier. Defaults to a UUID string.
        ///   - highlightedText: Bold accent prefix.
        ///   - description: Regular-weight description.
        ///   - iconName: SF Symbol name. Defaults to `"checkmark.circle.fill"`.
        public init(id: String = UUID().uuidString,
                    highlightedText: String,
                    description: String,
                    iconName: String = "checkmark.circle.fill") {
            self.id = id
            self.highlightedText = highlightedText
            self.description = description
            self.iconName = iconName
        }
    }
}
