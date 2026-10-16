import Foundation

/// Resolves payment dates from payment rules using a banking calendar.
nonisolated struct PaymentResolver: Sendable {
    let calendar: BankingCalendar

    init(calendar: BankingCalendar = BankingCalendar()) {
        self.calendar = calendar
    }

    /// The payment date for the source in the given month, or `nil` when the rule
    /// has no date in that month. When a rule pays more than once a month this is
    /// the first of them; use `dates(for:in:)` for all of them.
    func date(for source: PaymentSource, in month: Month) -> Date? {
        dates(for: source, in: month).first
    }

    /// The payment dates for the source in the given month, in date order.
    ///
    /// Monthly rules return at most one date; a rule that pays every few weeks
    /// returns however many of its occurrences land in the month.
    func dates(for source: PaymentSource, in month: Month) -> [Date] {
        switch source.rule {
        case let .fixedDayOfMonth(day, shift, alsoShiftOnWeekdays):
            calendar.day(day, of: month)
                .map { [adjusted($0, shift: shift, alsoShiftOnWeekdays: alsoShiftOnWeekdays)] } ?? []
        case .firstBankingDayOfMonth:
            [calendar.firstBankingDay(of: month)]
        case .lastBankingDayOfMonth:
            [calendar.lastBankingDay(of: month)]
        case .lastWeekdayOfMonth:
            [calendar.lastWeekday(of: month)]
        case let .nthBankingDayOfMonth(n):
            calendar.nthBankingDay(n, of: month).map { [$0] } ?? []
        case let .nthWeekdayOfMonth(n, weekday):
            nthWeekday(n, weekday, of: month).map { [$0] } ?? []
        case let .everyNthWeek(n, startingOn, shift):
            everyNthWeek(n, startingOn: startingOn, shift: shift, of: month)
        }
    }

    /// The next payment for the source on or after the given date.
    func nextOccurrence(for source: PaymentSource, onOrAfter date: Date) -> PaymentOccurrence? {
        occurrences(for: source, onOrAfter: date, count: 1).first
    }

    /// The source's most recent payment on or before the given date.
    func previousOccurrence(for source: PaymentSource, onOrBefore date: Date) -> PaymentOccurrence? {
        let end = calendar.startOfDay(date)
        var month = calendar.month(containing: end)
        var monthsChecked = 0
        while monthsChecked < 24 {
            if let date = dates(for: source, in: month).last(where: { $0 <= end }) {
                return PaymentOccurrence(sourceID: source.id, date: date)
            }
            month = month.previous
            monthsChecked += 1
        }
        return nil
    }

    /// The wait that the payment ends, or `nil` when the source has no earlier
    /// payment to measure it from.
    func cycle(endingAt payment: UpcomingPayment) -> PaymentCycle? {
        let dayBefore = calendar.adding(days: -1, to: payment.date)
        guard let previous = previousOccurrence(for: payment.source, onOrBefore: dayBefore)?.date else { return nil }
        return PaymentCycle(previous: previous, next: payment.date)
    }

    /// The source's next payments on or after the given date, in date order.
    func occurrences(for source: PaymentSource, onOrAfter date: Date, count: Int) -> [PaymentOccurrence] {
        guard count > 0 else { return [] }
        let start = calendar.startOfDay(date)
        var month = calendar.month(containing: start)
        var dates: [Date] = []
        var monthsChecked = 0
        while dates.count < count, monthsChecked < count + 24 {
            dates.append(contentsOf: self.dates(for: source, in: month).filter { $0 >= start })
            month = month.next
            monthsChecked += 1
        }
        return dates.prefix(count).map { PaymentOccurrence(sourceID: source.id, date: $0) }
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

    /// The occurrences of a week-interval rule that fall in the month.
    ///
    /// The series is anchored at `startingOn`, so it stays aligned across months
    /// instead of restarting in each one.
    private func everyNthWeek(_ n: Int, startingOn anchor: Date, shift: BankingDayShift, of month: Month) -> [Date] {
        guard n >= 1 else { return [] }
        let interval = n * 7
        let anchorDay = calendar.startOfDay(anchor)
        let monthStart = calendar.start(of: month)
        let monthEnd = calendar.adding(days: 1, to: calendar.lastDay(of: month))

        // The first multiple of the interval that reaches the month.
        let elapsed = max(0, calendar.dayCount(from: anchorDay, to: monthStart))
        var candidate = calendar.adding(days: (elapsed + interval - 1) / interval * interval, to: anchorDay)

        var dates: [Date] = []
        while candidate < monthEnd {
            dates.append(adjusted(candidate, shift: shift, alsoShiftOnWeekdays: []))
            candidate = calendar.adding(days: interval, to: candidate)
        }
        return dates
    }
}
