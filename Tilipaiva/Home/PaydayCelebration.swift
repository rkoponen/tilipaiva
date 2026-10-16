import Foundation

/// The state behind the payday celebration: whether the user wants it, and
/// whether it has already played today.
///
/// The moment belongs to the day, not to the launch. Opening the app again on
/// the same payday has to stay quiet, or the delight turns into noise, so the
/// day it last played on is remembered in the shared defaults — the same store
/// the payment sources live in, and one a test can point at a throwaway suite.
nonisolated struct PaydayCelebration: Sendable {
    /// The preference key. A missing value means "on", so the celebration
    /// arrives with the update without a trip to Settings.
    static let enabledKey = "celebrateOnPayday"

    /// The key of the Finnish day the celebration last played on.
    static let lastPlayedKey = "lastPaydayCelebration"

    private let suiteName: String?
    private let calendar: BankingCalendar

    /// Creates the state, backed by the given defaults suite, defaulting to the
    /// shared App Group container.
    init(suiteName: String? = SharedDefaults.appGroupID, calendar: BankingCalendar = BankingCalendar()) {
        self.suiteName = suiteName
        self.calendar = calendar
    }

    private var defaults: UserDefaults {
        SharedDefaults.defaults(suiteName: suiteName)
    }

    /// Whether the user has left the celebration on.
    var isEnabled: Bool {
        defaults.object(forKey: Self.enabledKey) as? Bool ?? true
    }

    /// Whether the celebration should play on the given date: it is wanted, and
    /// it has not played that day yet.
    func shouldPlay(on date: Date) -> Bool {
        isEnabled && !hasPlayed(on: date)
    }

    /// Records that the celebration played, so the rest of the day stays quiet.
    func markPlayed(on date: Date) {
        defaults.set(calendar.startOfDay(date), forKey: Self.lastPlayedKey)
    }

    /// Whether the celebration has already played on the given date.
    ///
    /// The day is the Finnish one, the same day the payment rules and the
    /// countdown work in, so the answer does not change while the user is in
    /// another time zone.
    private func hasPlayed(on date: Date) -> Bool {
        guard let played = defaults.object(forKey: Self.lastPlayedKey) as? Date else { return false }
        return calendar.startOfDay(played) == calendar.startOfDay(date)
    }
}
