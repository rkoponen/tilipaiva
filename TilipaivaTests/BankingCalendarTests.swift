import Foundation
import Testing
@testable import Tilipaiva

struct BankingCalendarTests {
    private let calendar = BankingCalendar()

    private var helsinki: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        helsinki.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func monthDay(_ date: Date) -> String {
        let components = helsinki.dateComponents([.month, .day], from: date)
        return "\(components.month!)-\(components.day!)"
    }

    private func monthDays(_ dates: Set<Date>) -> Set<String> {
        Set(dates.map(monthDay))
    }

    // MARK: - Easter

    @Test func easterSundayAcrossYears() {
        let expected = [(2024, 3, 31), (2025, 4, 20), (2026, 4, 5), (2027, 3, 28), (2028, 4, 16)]
        for (year, month, day) in expected {
            let easter = Easter.monthAndDay(in: year)
            #expect(easter.month == month, "Easter \(year)")
            #expect(easter.day == day, "Easter \(year)")
        }
    }

    // MARK: - Holidays

    @Test func bankHolidaysIn2026() {
        let expected: Set<String> = [
            "1-1",   // Uudenvuodenpäivä
            "1-6",   // Loppiainen
            "4-3",   // Pitkäperjantai
            "4-6",   // 2. pääsiäispäivä
            "5-1",   // Vappu
            "5-14",  // Helatorstai
            "6-19",  // Juhannusaatto
            "12-6",  // Itsenäisyyspäivä
            "12-24", // Jouluaatto
            "12-25", // Joulupäivä
            "12-26", // Tapaninpäivä
        ]
        #expect(monthDays(calendar.holidays(in: 2026)) == expected)
    }

    @Test func easterDependentHolidaysTrackTheYear() {
        // Easter 2027 falls on 28 March, so Good Friday is 26 March.
        #expect(monthDays(calendar.holidays(in: 2027)).isSuperset(of: ["3-26", "3-29"]))
        // Easter 2028 falls on 16 April, so Good Friday is 14 April.
        #expect(monthDays(calendar.holidays(in: 2028)).isSuperset(of: ["4-14", "4-17"]))
    }

    @Test func weekendsAndHolidaysAreNotBankingDays() {
        #expect(!calendar.isBankingDay(day(2026, 1, 3)))   // Saturday
        #expect(!calendar.isBankingDay(day(2026, 1, 4)))   // Sunday
        #expect(!calendar.isBankingDay(day(2026, 4, 3)))   // Good Friday
        #expect(calendar.isBankingDay(day(2026, 4, 7)))    // ordinary Tuesday
    }

    // MARK: - Banking-day navigation

    @Test func bankingDayNavigationSkipsHolidaysAndWeekends() {
        #expect(calendar.previousBankingDay(before: day(2026, 5, 1)) == day(2026, 4, 30))
        #expect(calendar.nextBankingDay(after: day(2026, 4, 30)) == day(2026, 5, 4))
        #expect(calendar.previousBankingDay(before: day(2026, 12, 28)) == day(2026, 12, 23))
        #expect(calendar.nextBankingDay(after: day(2026, 12, 23)) == day(2026, 12, 28))
    }

    // MARK: - Month-relative days

    @Test func monthRelativeBankingDays() {
        let february = Month(year: 2026, month: 2)
        #expect(calendar.firstBankingDay(of: february) == day(2026, 2, 2))
        #expect(calendar.nthBankingDay(1, of: february) == day(2026, 2, 2))
        #expect(calendar.nthBankingDay(2, of: february) == day(2026, 2, 3))
        #expect(calendar.lastBankingDay(of: february) == day(2026, 2, 27))
        #expect(calendar.lastWeekday(of: february) == day(2026, 2, 27))
    }

    @Test func lastWeekdayAndLastBankingDayDifferOnAHoliday() {
        // March 2024 ends on a Sunday, and Good Friday is the 29th.
        let march = Month(year: 2024, month: 3)
        #expect(calendar.lastWeekday(of: march) == day(2024, 3, 29))
        #expect(calendar.lastBankingDay(of: march) == day(2024, 3, 28))
    }
}
