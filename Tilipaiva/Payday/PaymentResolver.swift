import Foundation

/// Resolves payment dates from payment rules using a banking calendar.
nonisolated struct PaymentResolver: Sendable {
    let calendar: BankingCalendar

    init(calendar: BankingCalendar = BankingCalendar()) {
        self.calendar = calendar
    }

    /// The payment date for the source in the given month, or `nil` when the rule
    /// has no date in that month.
    func date(for source: PaymentSource, in month: Month) -> Date? {
        switch source.rule {
        case let .fixedDayOfMonth(day, shift, alsoShiftOnWeekdays):
            calendar.day(day, of: month).map {
                adjusted($0, shift: shift, alsoShiftOnWeekdays: alsoShiftOnWeekdays)
            }
        case .firstBankingDayOfMonth:
            calendar.firstBankingDay(of: month)
        case .lastBankingDayOfMonth:
            calendar.lastBankingDay(of: month)
        case .lastWeekdayOfMonth:
            calendar.lastWeekday(of: month)
        case let .nthBankingDayOfMonth(n):
            calendar.nthBankingDay(n, of: month)
        case let .nthWeekdayOfMonth(n, weekday):
            nthWeekday(n, weekday, of: month)
        }
    }

    /// The next payment for the source on or after the given date.
    func nextOccurrence(for source: PaymentSource, onOrAfter date: Date) -> PaymentOccurrence? {
        occurrences(for: source, onOrAfter: date, count: 1).first
    }

    /// The source's next payments on or after the given date, in date order.
    func occurrences(for source: PaymentSource, onOrAfter date: Date, count: Int) -> [PaymentOccurrence] {
        guard count > 0 else { return [] }
        let start = calendar.startOfDay(date)
        var month = calendar.month(containing: start)
        var occurrences: [PaymentOccurrence] = []
        var monthsChecked = 0
        while occurrences.count < count, monthsChecked < count + 24 {
            if let date = self.date(for: source, in: month), date >= start {
                occurrences.append(PaymentOccurrence(sourceID: source.id, date: date))
            }
            month = month.next
            monthsChecked += 1
        }
        return occurrences
    }

    /// The soonest payments across the sources, in date order.
    func upcoming(for sources: [PaymentSource], onOrAfter date: Date, limit: Int) -> [UpcomingPayment] {
        guard limit > 0 else { return [] }
        let payments = sources.flatMap { source in
            occurrences(for: source, onOrAfter: date, count: limit)
                .map { UpcomingPayment(source: source, occurrence: $0) }
        }
        return Array(payments.sorted().prefix(limit))
    }

    /// The single next payment across the sources.
    func next(for sources: [PaymentSource], onOrAfter date: Date) -> UpcomingPayment? {
        upcoming(for: sources, onOrAfter: date, limit: 1).first
    }

    // MARK: - Private helpers

    private func adjusted(_ base: Date, shift: BankingDayShift, alsoShiftOnWeekdays: Set<Weekday>) -> Date {
        let shifts = !calendar.isBankingDay(base) || alsoShiftOnWeekdays.contains(calendar.weekday(of: base))
        guard shifts else { return base }
        switch shift {
        case .none:
            return base
        case .previousBankingDay:
            return calendar.previousBankingDay(before: base)
        case .nextBankingDay:
            return calendar.nextBankingDay(after: base)
        }
    }

    private func nthWeekday(_ n: Int, _ weekday: Weekday, of month: Month) -> Date? {
        guard n >= 1, let first = calendar.day(1, of: month) else { return nil }
        let offset = (weekday.calendarComponent - calendar.weekday(of: first).calendarComponent + 7) % 7
        return calendar.day(1 + offset + (n - 1) * 7, of: month)
    }
}
