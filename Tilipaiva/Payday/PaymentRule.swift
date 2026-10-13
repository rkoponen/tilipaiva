import Foundation

/// How a recurring payment date is derived within each month.
///
/// The encoded form uses a `type` discriminator so it can live in `Benefits.json`
/// and in stored payment sources.
nonisolated enum PaymentRule: Hashable, Sendable {
    /// A fixed day of the month, optionally adjusted to a banking day.
    ///
    /// `alsoShiftOnWeekdays` forces a shift on the listed weekdays even when they
    /// are banking days, which Kela uses for benefits such as Lapsilisä.
    case fixedDayOfMonth(day: Int, shift: BankingDayShift, alsoShiftOnWeekdays: Set<Weekday>)

    /// The first banking day of the month.
    case firstBankingDayOfMonth

    /// The last banking day of the month.
    case lastBankingDayOfMonth

    /// The last weekday (Monday–Friday) of the month, holidays included.
    case lastWeekdayOfMonth

    /// The nth banking day of the month, where the first banking day is `n == 1`.
    case nthBankingDayOfMonth(n: Int)

    /// The nth given weekday of the month, e.g. the second Friday.
    case nthWeekdayOfMonth(n: Int, weekday: Weekday)
}

extension PaymentRule: Codable {
    private enum Kind: String, Codable {
        case fixedDayOfMonth
        case firstBankingDayOfMonth
        case lastBankingDayOfMonth
        case lastWeekdayOfMonth
        case nthBankingDayOfMonth
        case nthWeekdayOfMonth
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case day
        case shift
        case alsoShiftOnWeekdays
        case n
        case weekday
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .type) {
        case .fixedDayOfMonth:
            self = .fixedDayOfMonth(
                day: try container.decode(Int.self, forKey: .day),
                shift: try container.decodeIfPresent(BankingDayShift.self, forKey: .shift) ?? .none,
                alsoShiftOnWeekdays: try container.decodeIfPresent(Set<Weekday>.self, forKey: .alsoShiftOnWeekdays) ?? []
            )
        case .firstBankingDayOfMonth:
            self = .firstBankingDayOfMonth
        case .lastBankingDayOfMonth:
            self = .lastBankingDayOfMonth
        case .lastWeekdayOfMonth:
            self = .lastWeekdayOfMonth
        case .nthBankingDayOfMonth:
            self = .nthBankingDayOfMonth(n: try container.decode(Int.self, forKey: .n))
        case .nthWeekdayOfMonth:
            self = .nthWeekdayOfMonth(
                n: try container.decode(Int.self, forKey: .n),
                weekday: try container.decode(Weekday.self, forKey: .weekday)
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .fixedDayOfMonth(day, shift, alsoShiftOnWeekdays):
            try container.encode(Kind.fixedDayOfMonth, forKey: .type)
            try container.encode(day, forKey: .day)
            try container.encode(shift, forKey: .shift)
            if !alsoShiftOnWeekdays.isEmpty {
                try container.encode(alsoShiftOnWeekdays, forKey: .alsoShiftOnWeekdays)
            }
        case .firstBankingDayOfMonth:
            try container.encode(Kind.firstBankingDayOfMonth, forKey: .type)
        case .lastBankingDayOfMonth:
            try container.encode(Kind.lastBankingDayOfMonth, forKey: .type)
        case .lastWeekdayOfMonth:
            try container.encode(Kind.lastWeekdayOfMonth, forKey: .type)
        case let .nthBankingDayOfMonth(n):
            try container.encode(Kind.nthBankingDayOfMonth, forKey: .type)
            try container.encode(n, forKey: .n)
        case let .nthWeekdayOfMonth(n, weekday):
            try container.encode(Kind.nthWeekdayOfMonth, forKey: .type)
            try container.encode(n, forKey: .n)
            try container.encode(weekday, forKey: .weekday)
        }
    }
}
