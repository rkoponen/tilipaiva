import Foundation
import os

/// Persists the user's payment sources in the shared App Group container, so the
/// app and its widget read and write the same data.
nonisolated struct PaymentSourceStore: Sendable {
    private let suiteName: String?

    /// Creates a store backed by the given defaults suite, defaulting to the
    /// shared App Group container. Falls back to the standard domain when the
    /// suite is unavailable, such as in a unit test without an entitlement.
    init(suiteName: String? = SharedDefaults.appGroupID) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        SharedDefaults.defaults(suiteName: suiteName)
    }

    /// The stored sources, or an empty list when nothing has been saved.
    func load() -> [PaymentSource] {
        guard let data = defaults.data(forKey: SharedDefaults.sourcesKey) else { return [] }
        do {
            return try JSONDecoder().decode([PaymentSource].self, from: data)
        } catch {
            Self.logger.error("Failed to decode payment sources: \(error.localizedDescription)")
            return []
        }
    }

    /// Replaces the stored sources.
    func save(_ sources: [PaymentSource]) {
        do {
            defaults.set(try JSONEncoder().encode(sources), forKey: SharedDefaults.sourcesKey)
        } catch {
            Self.logger.error("Failed to encode payment sources: \(error.localizedDescription)")
        }
    }

    private static let logger = Logger(subsystem: "fi.ruupert.Tilipaiva", category: "PaymentSourceStore")
}
