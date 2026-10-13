import Foundation

/// The App Group container shared between the app and its widget.
nonisolated enum SharedDefaults {
    /// The App Group identifier, declared in both entitlements files.
    static let appGroupID = "group.fi.ruupert.Tilipaiva"

    /// The key the payment sources are stored under.
    static let sourcesKey = "paymentSources"
}
