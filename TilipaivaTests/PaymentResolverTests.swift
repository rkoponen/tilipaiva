import Foundation
import Testing
@testable import Tilipaiva

struct PaymentResolverTests {
    private let resolver = PaymentResolver()

    private var helsinki: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        helsinki.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func source(_ rule: PaymentRule) -> PaymentSource {
        PaymentSource.salary(name: "Test", rule: rule)
    }

    @Test func fixedDayShiftsToThePreviousBankingDay() {
        let source = source(.fixedDayOfMonth(day: 7, shift: .previousBankingDay, alsoShiftOnWeekdays: []))
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 2)) == day(2026, 2, 6))
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 4)) == day(2026, 4, 7))
    }

    @Test func fixedDayShiftsToTheNextBankingDay() {
        let source = source(.fixedDayOfMonth(day: 1, shift: .nextBankingDay, alsoShiftOnWeekdays: []))
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 5)) == day(2026, 5, 4))
    }

    @Test func fixedDayWithoutShiftIgnoresWeekends() {
        // 15 August 2026 is a Saturday.
        let source = source(.fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 8)) == day(2026, 8, 15))
    }

    @Test func forcedWeekdayShiftAppliesOnBankingDays() {
        let source = source(.fixedDayOfMonth(day: 26, shift: .previousBankingDay, alsoShiftOnWeekdays: [.monday]))
        // The 26th is a Monday, so it moves back to the previous Friday.
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 1)) == day(2026, 1, 23))
        // A Thursday is a banking day and is left alone.
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 2)) == day(2026, 2, 26))
    }

    @Test func nthBankingDayAndNthWeekday() {
        #expect(resolver.date(for: source(.nthBankingDayOfMonth(n: 2)), in: Month(year: 2026, month: 2)) == day(2026, 2, 3))
        #expect(resolver.date(for: source(.nthWeekdayOfMonth(n: 2, weekday: .friday)), in: Month(year: 2026, month: 3)) == day(2026, 3, 13))
    }

    @Test func firstAndLastBankingDays() {
        #expect(resolver.date(for: source(.firstBankingDayOfMonth), in: Month(year: 2026, month: 5)) == day(2026, 5, 4))
        #expect(resolver.date(for: source(.lastBankingDayOfMonth), in: Month(year: 2026, month: 5)) == day(2026, 5, 29))
    }

    @Test func nextOccurrenceUsesTodayWhenItIsPayday() {
        let source = source(.fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 3, 1))?.date == day(2026, 3, 15))
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 3, 15))?.date == day(2026, 3, 15))
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 3, 16))?.date == day(2026, 4, 15))
    }

    @Test func upcomingMergesSourcesInDateOrder() {
        let salary = PaymentSource.salary(name: "Palkka", rule: .fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        let benefit = PaymentSource.salary(name: "Lapsilisä", rule: .fixedDayOfMonth(day: 26, shift: .previousBankingDay, alsoShiftOnWeekdays: [.monday]))
        let upcoming = resolver.upcoming(for: [salary, benefit], onOrAfter: day(2026, 1, 1), limit: 3)
        #expect(upcoming.map(\.date) == [day(2026, 1, 15), day(2026, 1, 23), day(2026, 2, 15)])
    }

    @Test func paymentRuleRoundTripsThroughJSON() throws {
        let rules: [PaymentRule] = [
            .fixedDayOfMonth(day: 26, shift: .previousBankingDay, alsoShiftOnWeekdays: [.monday]),
            .firstBankingDayOfMonth,
            .lastBankingDayOfMonth,
            .lastWeekdayOfMonth,
            .nthBankingDayOfMonth(n: 2),
            .nthWeekdayOfMonth(n: 2, weekday: .friday),
        ]
        for rule in rules {
            let data = try JSONEncoder().encode(rule)
            #expect(try JSONDecoder().decode(PaymentRule.self, from: data) == rule)
        }
    }
}
