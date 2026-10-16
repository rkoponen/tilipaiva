import Foundation

/// A month in the proleptic Gregorian calendar, independent of time zone.
nonisolated struct Month: Hashable, Comparable, Sendable {
    var year: Int
    var month: Int

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    /// The month that contains the date.
    init(containing date: Date, in calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month], from: date)
        self.init(year: components.year!, month: components.month!)
    }

    static func < (lhs: Month, rhs: Month) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }

    /// The following month, rolling over to January of the next year.
    var next: Month {
        month == 12 ? Month(year: year + 1, month: 1) : Month(year: year, month: month + 1)
    }

    /// The preceding month, rolling back to December of the previous year.
    var previous: Month {
        month == 1 ? Month(year: year - 1, month: 12) : Month(year: year, month: month - 1)
    }

    /// The first moment of the month in the given calendar.
    func start(in calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: 1))!
    }

    /// The number of days in the month.
    func dayCount(in calendar: Calendar) -> Int {
        calendar.range(of: .day, in: .month, for: start(in: calendar))!.count
    }
}
