import Foundation

/// The App Group container shared between the app and its widget.
nonisolated enum SharedDefaults {
    /// The App Group identifier, declared in both entitlements files.
    static let appGroupID = "group.fi.ruupert.Tilipaiva"

    /// The key the payment sources are stored under.
    static let sourcesKey = "paymentSources"

    /// The key the hero's progress style is stored under.
    static let progressStyleKey = "progressStyle"

    /// The shared defaults, falling back to the standard domain when the App
    /// Group is unavailable, such as in a unit test without an entitlement.
    static var shared: UserDefaults {
        defaults(suiteName: appGroupID)
    }

    /// The defaults for a suite, with the same fallback as `shared`.
    static func defaults(suiteName: String?) -> UserDefaults {
        suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }
}
