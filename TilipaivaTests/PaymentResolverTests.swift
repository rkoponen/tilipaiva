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

    @Test func everyNthWeekKeepsItsCadenceAcrossMonths() {
        // 2 January 2026 is a Friday, so the series pays every other Friday.
        let source = source(.everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay))
        #expect(resolver.occurrences(for: source, onOrAfter: day(2026, 1, 2), count: 3).map(\.date)
            == [day(2026, 1, 2), day(2026, 1, 16), day(2026, 1, 30)])
        // The series is anchored, not restarted: nothing falls between two dates.
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 1, 31))?.date == day(2026, 2, 13))
    }

    @Test func everyNthWeekShiftsAHolidayPayday() {
        // Midsummer Eve, Friday 19 June 2026, is a bank holiday, so that payday
        // moves back to the previous banking day while the cadence stays put.
        let source = source(.everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay))
        #expect(resolver.occurrences(for: source, onOrAfter: day(2026, 6, 1), count: 3).map(\.date)
            == [day(2026, 6, 5), day(2026, 6, 18), day(2026, 7, 3)])
    }

    @Test func everyNthWeekWithoutShiftKeepsWeekendPaydays() {
        let source = source(.everyNthWeek(n: 2, startingOn: day(2026, 1, 3), shift: .none))
        #expect(resolver.occurrences(for: source, onOrAfter: day(2026, 1, 1), count: 3).map(\.date)
            == [day(2026, 1, 3), day(2026, 1, 17), day(2026, 1, 31)])
    }

    @Test func aMonthCanHoldSeveralOccurrences() {
        let source = source(.everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay))
        #expect(resolver.dates(for: source, in: Month(year: 2026, month: 2)) == [day(2026, 2, 13), day(2026, 2, 27)])
        #expect(resolver.date(for: source, in: Month(year: 2026, month: 2)) == day(2026, 2, 13))
    }

    @Test func nextOccurrenceUsesTodayWhenItIsPayday() {
        let source = source(.fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 3, 1))?.date == day(2026, 3, 15))
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 3, 15))?.date == day(2026, 3, 15))
        #expect(resolver.nextOccurrence(for: source, onOrAfter: day(2026, 3, 16))?.date == day(2026, 4, 15))
    }

    @Test func previousOccurrenceLooksBackwards() {
        let monthly = source(.lastBankingDayOfMonth)
        #expect(resolver.previousOccurrence(for: monthly, onOrBefore: day(2026, 10, 15))?.date == day(2026, 9, 30))
        // On a payment day the payment before is that same day.
        #expect(resolver.previousOccurrence(for: monthly, onOrBefore: day(2026, 10, 30))?.date == day(2026, 10, 30))

        let biweekly = source(.everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay))
        #expect(resolver.previousOccurrence(for: biweekly, onOrBefore: day(2026, 1, 31))?.date == day(2026, 1, 30))
        // A series knows nothing before its anchor.
        #expect(resolver.previousOccurrence(for: biweekly, onOrBefore: day(2025, 12, 31)) == nil)
    }

    @Test func cycleRunsFromThePreviousPaymentToTheNext() {
        let monthly = source(.lastBankingDayOfMonth)
        let payment = UpcomingPayment(
            source: monthly,
            occurrence: resolver.nextOccurrence(for: monthly, onOrAfter: day(2026, 10, 1))!
        )
        let cycle = resolver.cycle(endingAt: payment)
        #expect(cycle?.previous == day(2026, 9, 30))
        #expect(cycle?.next == day(2026, 10, 30))
        #expect(cycle?.fraction(on: day(2026, 10, 15)) == 0.5)

        // A fortnight is a complete wait too, so the ring moves twice as fast.
        let biweekly = source(.everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay))
        let fortnight = UpcomingPayment(
            source: biweekly,
            occurrence: resolver.nextOccurrence(for: biweekly, onOrAfter: day(2026, 1, 17))!
        )
        let biweeklyCycle = resolver.cycle(endingAt: fortnight)
        #expect(biweeklyCycle?.previous == day(2026, 1, 16))
        #expect(biweeklyCycle?.next == day(2026, 1, 30))
        #expect(biweeklyCycle?.fraction(on: day(2026, 1, 23)) == 0.5)
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
            .everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay),
        ]
        for rule in rules {
            let data = try JSONEncoder().encode(rule)
            #expect(try JSONDecoder().decode(PaymentRule.self, from: data) == rule)
        }
    }
}
