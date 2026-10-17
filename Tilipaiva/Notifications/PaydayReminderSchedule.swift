import Foundation

/// The reminders a set of sources calls for.
///
/// This is the part worth testing: it turns the user's sources into payment days
/// without touching the notification centre, so the banking-day rules, the
/// grouping and the window are all exercised by unit tests.
/// `PaydayNotifications` is left as the thin wrapper that hands the result to
/// the system.
nonisolated struct PaydayReminderSchedule: Sendable {
    /// The Finnish morning the reminder arrives at, as an hour of the day.
    ///
    /// Banks settle payments overnight, so the money is in the account by nine.
    static let hour = 9

    /// How many payment days are scheduled ahead.
    ///
    /// iOS keeps at most 64 pending notifications for an app, so the app holds a
    /// window rather than everything the rules can produce; the window slides
    /// forward every time the app comes to the foreground.
    static let limit = 20

    /// The prefix every request the app adds carries, so the ones it owns can be
    /// told apart from anything else the system holds.
    static let identifierPrefix = "payday."

    let calendar: BankingCalendar
    let resolver: PaymentResolver

    /// The Finnish calendar, for the two things `BankingCalendar` does not
    /// expose: the hour within a day, and a day's number for an identifier.
    private let zone: Calendar

    init(calendar: BankingCalendar = BankingCalendar(), resolver: PaymentResolver = PaymentResolver()) {
        self.calendar = calendar
        self.resolver = resolver
        var zone = Calendar(identifier: .gregorian)
        zone.timeZone = BankingCalendar.timeZone
        self.zone = zone
    }

    /// The reminders for the sources, soonest first, one per payment day.
    ///
    /// A day whose Finnish morning has already gone is left out: the system
    /// would not deliver a trigger set in the past.
    func reminders(for sources: [PaymentSource], onOrAfter date: Date) -> [PaydayReminder] {
        // Enough payments that a handful of sources still fill the window: the
        // resolver returns payments, and several of them can share a day.
        let payments = resolver.upcoming(for: sources, onOrAfter: date, limit: Self.limit * max(1, sources.count))

        var days: [Date] = []
        var titlesByDay: [Date: [String]] = [:]
        for payment in payments {
            let day = calendar.startOfDay(payment.date)
            if titlesByDay[day] == nil { days.append(day) }
            titlesByDay[day, default: []].append(payment.title)
        }

        let reminders = days.compactMap { day -> PaydayReminder? in
            guard let titles = titlesByDay[day], moment(for: day) > date else { return nil }
            return PaydayReminder(id: identifier(for: day), day: day, titles: titles)
        }
        return Array(reminders.prefix(Self.limit))
    }

    /// The Finnish morning of a payment day: nine o'clock in Helsinki.
    func moment(for day: Date) -> Date {
        zone.date(byAdding: .hour, value: Self.hour, to: calendar.startOfDay(day))!
    }

    /// The identifier a payment day's request is stored under.
    func identifier(for day: Date) -> String {
        let parts = zone.dateComponents([.year, .month, .day], from: day)
        return String(format: "%@%04d-%02d-%02d", Self.identifierPrefix, parts.year!, parts.month!, parts.day!)
    }
}
