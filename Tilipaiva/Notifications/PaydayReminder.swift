import Foundation

/// One reminder the app sends: a payment day, and the payments that land on it.
///
/// The day, not the payment, is the unit. Two sources that pay on the same date
/// are one notification — "Palkka ja elatustuki saapuvat tänään" — rather than
/// two banners a moment apart.
nonisolated struct PaydayReminder: Identifiable, Hashable, Sendable {
    /// The identifier the request is stored under, e.g. "payday.2026-10-30".
    ///
    /// It carries the day, so rescheduling a day replaces its request instead of
    /// adding a second one beside it.
    let id: String

    /// The Finnish day the payments arrive on.
    let day: Date

    /// The sources paying that day, by their localized names, in the order the
    /// resolver returned them.
    let titles: [String]

    /// The body of the notification.
    ///
    /// A single payment and several read differently in Finnish — "saapuu"
    /// against "saapuvat" — so the sentence is chosen by count. A plural rule
    /// would count the number in the string, and there is none.
    var message: String {
        let joined = ListFormatter.localizedString(byJoining: titles)
        return titles.count == 1
            ? String(localized: "\(joined) arrives today.")
            : String(localized: "\(joined) arrive today.")
    }
}
