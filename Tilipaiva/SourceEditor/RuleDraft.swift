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

        var id: Self { self }

        /// The localized picker label.
        var title: LocalizedStringKey {
            switch self {
            case .dayOfMonth: "Day of month"
            case .firstBankingDay: "First banking day"
            case .lastBankingDay: "Last banking day"
            case .lastWeekday: "Last weekday"
            case .nthBankingDay: "Nth banking day"
            case .nthWeekday: "Nth weekday"
            }
        }
    }

    var kind: Kind = .dayOfMonth
    var day = 15
    var shift: BankingDayShift = .none
    var nth = 1
    var weekday: Weekday = .friday

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
        }
    }
}
