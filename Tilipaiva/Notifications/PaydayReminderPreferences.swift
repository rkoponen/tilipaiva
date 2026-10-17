import Foundation

/// Whether the user wants the payment reminder.
///
/// A missing value means "off", unlike the payday celebration: a reminder cannot
/// arrive at all without the system's permission, so it must not come on by
/// itself. The key lives in the shared store for the same reason the celebration
/// does — a test can point it at a throwaway suite.
nonisolated struct PaydayReminderPreferences: Sendable {
    /// The preference key.
    static let enabledKey = "paydayRemindersEnabled"

    private let suiteName: String?

    /// Creates the preference, backed by the given defaults suite, defaulting to
    /// the shared App Group container.
    init(suiteName: String? = SharedDefaults.appGroupID) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        SharedDefaults.defaults(suiteName: suiteName)
    }

    /// Whether the user has left the reminder on.
    var isEnabled: Bool {
        defaults.bool(forKey: Self.enabledKey)
    }

    /// Remembers the user's choice.
    func setEnabled(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: Self.enabledKey)
    }
}
