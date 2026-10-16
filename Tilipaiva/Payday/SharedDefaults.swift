import Foundation

/// The App Group container shared between the app and its widget.
nonisolated enum SharedDefaults {
    /// The App Group identifier, declared in both entitlements files.
    static let appGroupID = "group.fi.ruupert.Tilipaiva"

    /// The key the payment sources are stored under.
    static let sourcesKey = "paymentSources"

    /// The defaults for a suite, falling back to the standard domain when the
    /// App Group is unavailable, such as in a unit test without an entitlement.
    static func defaults(suiteName: String?) -> UserDefaults {
        suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }
}
