import Foundation

/// A day of the week, ordered the ISO 8601 way with Monday first.
nonisolated enum Weekday: String, Codable, CaseIterable, Sendable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    /// The matching `Calendar` weekday component, where Sunday is `1`.
    var calendarComponent: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        }
    }

    /// Creates a weekday from a `Calendar` weekday component, where Sunday is `1`.
    init?(calendarComponent: Int) {
        switch calendarComponent {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }

    /// Whether the day is Monday through Friday, ignoring holidays.
    var isWeekday: Bool {
        switch self {
        case .saturday, .sunday: false
        default: true
        }
    }

    /// The localized full weekday name in the given locale.
    func name(in locale: Locale) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        return calendar.standaloneWeekdaySymbols[calendarComponent - 1]
    }
}
