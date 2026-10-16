import Foundation

/// Computes Finnish banking days ("pankkipäivä"): Monday–Friday excluding the
/// Bank of Finland's holiday list.
///
/// Holiday dates are derived from fixed dates and Easter, so the calendar needs
/// no yearly updates. Finnish bank holidays are not the same as public holidays:
/// Midsummer Eve and Christmas Eve are banking holidays too.
nonisolated struct BankingCalendar: Sendable {
    /// Finnish bank holidays are observed in Finnish local time.
    static let timeZone = TimeZone(identifier: "Europe/Helsinki")!

    private let calendar: Calendar

    init(timeZone: TimeZone = BankingCalendar.timeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "fi_FI")
        self.calendar = calendar
    }

    // MARK: - Banking days

    /// Whether the date is a weekday that is not a bank holiday.
    func isBankingDay(_ date: Date) -> Bool {
        weekday(of: date).isWeekday && !isHoliday(date)
    }

    /// The latest banking day on or before the date.
    func bankingDay(onOrBefore date: Date) -> Date {
        var candidate = startOfDay(date)
        while !isBankingDay(candidate) {
            candidate = adding(days: -1, to: candidate)
        }
        return candidate
    }

    /// The earliest banking day on or after the date.
    func bankingDay(onOrAfter date: Date) -> Date {
        var candidate = startOfDay(date)
        while !isBankingDay(candidate) {
            candidate = adding(days: 1, to: candidate)
        }
        return candidate
    }

    /// The first banking day strictly after the date.
    func nextBankingDay(after date: Date) -> Date {
        bankingDay(onOrAfter: adding(days: 1, to: startOfDay(date)))
    }

    /// The last banking day strictly before the date.
    func previousBankingDay(before date: Date) -> Date {
        bankingDay(onOrBefore: adding(days: -1, to: startOfDay(date)))
    }

    // MARK: - Month-relative days

    /// The first day of the month.
    func start(of month: Month) -> Date {
        month.start(in: calendar)
    }

    /// The last day of the month.
    func lastDay(of month: Month) -> Date {
        date(year: month.year, month: month.month, day: month.dayCount(in: calendar))
    }

    /// The first banking day of the month.
    func firstBankingDay(of month: Month) -> Date {
        bankingDay(onOrAfter: start(of: month))
    }

    /// The last banking day of the month.
    func lastBankingDay(of month: Month) -> Date {
        bankingDay(onOrBefore: lastDay(of: month))
    }

    /// The last Monday–Friday day of the month, holidays included.
    func lastWeekday(of month: Month) -> Date {
        var candidate = lastDay(of: month)
        while !weekday(of: candidate).isWeekday {
            candidate = adding(days: -1, to: candidate)
        }
        return candidate
    }

    /// The nth banking day of the month, where the first banking day is `n == 1`.
    func nthBankingDay(_ n: Int, of month: Month) -> Date? {
        guard n >= 1 else { return nil }
        var candidate = firstBankingDay(of: month)
        for _ in 1..<n {
            candidate = nextBankingDay(after: candidate)
        }
        return candidate
    }

    /// The day of the month, or `nil` when the month has no such day.
    func day(_ day: Int, of month: Month) -> Date? {
        guard (1...month.dayCount(in: calendar)).contains(day) else { return nil }
        return calendar.date(from: DateComponents(year: month.year, month: month.month, day: day))
    }

    // MARK: - Date helpers

    /// The month that contains the date.
    func month(containing date: Date) -> Month {
        Month(containing: date, in: calendar)
    }

    /// The date a number of days after the given date.
    func adding(days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date)!
    }

    /// The start of the day that contains the date.
    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// The weekday of the date.
    func weekday(of date: Date) -> Weekday {
        Weekday(calendarComponent: calendar.component(.weekday, from: date))!
    }

    /// The number of whole days from the start of one day to the start of another.
    func dayCount(from start: Date, to end: Date) -> Int {
        calendar.dateComponents([.day], from: startOfDay(start), to: startOfDay(end)).day ?? 0
    }

    // MARK: - Holidays

    /// Whether the date is a Finnish bank holiday.
    func isHoliday(_ date: Date) -> Bool {
        holidays(in: calendar.component(.year, from: date)).contains(startOfDay(date))
    }

    /// The Finnish bank holidays in the given year.
    func holidays(in year: Int) -> Set<Date> {
        let easter = Easter.monthAndDay(in: year)
        let easterSunday = date(year: year, month: easter.month, day: easter.day)
        return [
            date(year: year, month: 1, day: 1),         // Uudenvuodenpäivä
            date(year: year, month: 1, day: 6),         // Loppiainen
            adding(days: -2, to: easterSunday),         // Pitkäperjantai
            adding(days: 1, to: easterSunday),          // 2. pääsiäispäivä
            date(year: year, month: 5, day: 1),         // Vappu
            adding(days: 39, to: easterSunday),         // Helatorstai
            friday(in: year, month: 6, days: 19...25),  // Juhannusaatto
            date(year: year, month: 12, day: 6),        // Itsenäisyyspäivä
            date(year: year, month: 12, day: 24),       // Jouluaatto
            date(year: year, month: 12, day: 25),       // Joulupäivä
            date(year: year, month: 12, day: 26),       // Tapaninpäivä
        ]
    }

    // MARK: - Private helpers

    private func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// The Friday within the given July-week style window, e.g. Midsummer Eve.
    private func friday(in year: Int, month: Int, days: ClosedRange<Int>) -> Date {
        let lowerBound = date(year: year, month: month, day: days.lowerBound)
        let offset = (Weekday.friday.calendarComponent - weekday(of: lowerBound).calendarComponent + 7) % 7
        return adding(days: offset, to: lowerBound)
    }
}
