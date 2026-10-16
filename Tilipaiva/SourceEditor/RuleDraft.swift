import SwiftUI

/// Editable form of a `PaymentRule`, so the rule picker can bind to plain fields.
struct RuleDraft: Equatable {
    /// The kinds of payday rule the user can choose from.
    enum Kind: String, CaseIterable, Identifiable {
        case dayOfMonth
        case firstBankingDay
        case lastBankingDay
        case lastWeekday
        case nthBankingDay
        case nthWeekday
        case everyNthWeek

        var id: Self { self }

        /// The kinds the picker offers, most common first.
        ///
        /// `lastWeekday` is missing on purpose: the Kela benefit that needs it
        /// takes its rule from the catalog, so nothing new should be able to
        /// pick it, but rules saved earlier still have to resolve and round-trip.
        static let selectable: [Kind] = [
            .lastBankingDay,
            .dayOfMonth,
            .firstBankingDay,
            .nthBankingDay,
            .nthWeekday,
            .everyNthWeek,
        ]

        /// The localized picker label.
        var title: LocalizedStringKey {
            switch self {
            case .dayOfMonth: "Day of month"
            case .firstBankingDay: "First banking day"
            case .lastBankingDay: "Last banking day"
            case .lastWeekday: "Last weekday"
            case .nthBankingDay: "Nth banking day"
            case .nthWeekday: "Nth weekday"
            case .everyNthWeek: "Every Nth week"
            }
        }
    }

    var kind: Kind = .lastBankingDay
    var day = 15
    var shift: BankingDayShift = .previousBankingDay
    var nth = 1
    var weekday: Weekday = .friday
    var weeks = 2
    var startingOn = Date()

    init(_ rule: PaymentRule) {
        switch rule {
        case let .fixedDayOfMonth(day, shift, _):
            self.kind = .dayOfMonth
            self.day = day
            self.shift = shift
        case .firstBankingDayOfMonth:
            kind = .firstBankingDay
        case .lastBankingDayOfMonth:
            kind = .lastBankingDay
        case .lastWeekdayOfMonth:
            kind = .lastWeekday
        case let .nthBankingDayOfMonth(n):
            kind = .nthBankingDay
            nth = n
        case let .nthWeekdayOfMonth(n, weekday):
            kind = .nthWeekday
            nth = n
            self.weekday = weekday
        case let .everyNthWeek(n, startingOn, shift):
            kind = .everyNthWeek
            weeks = n
            self.startingOn = startingOn
            self.shift = shift
        }
    }

    /// The rule described by the current fields.
    var rule: PaymentRule {
        switch kind {
        case .dayOfMonth:
            .fixedDayOfMonth(day: day, shift: shift, alsoShiftOnWeekdays: [])
        case .firstBankingDay:
            .firstBankingDayOfMonth
        case .lastBankingDay:
            .lastBankingDayOfMonth
        case .lastWeekday:
            .lastWeekdayOfMonth
        case .nthBankingDay:
            .nthBankingDayOfMonth(n: nth)
        case .nthWeekday:
            .nthWeekdayOfMonth(n: nth, weekday: weekday)
        case .everyNthWeek:
            .everyNthWeek(n: weeks, startingOn: startingOn, shift: shift)
        }
    }
}
