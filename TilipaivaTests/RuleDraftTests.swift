import Foundation
import Testing
@testable import Tilipaiva

@MainActor
struct RuleDraftTests {
    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// Every rule the picker can produce survives a round trip through the draft.
    @Test func rulesRoundTripThroughTheDraft() {
        let rules: [PaymentRule] = [
            .fixedDayOfMonth(day: 15, shift: .previousBankingDay, alsoShiftOnWeekdays: []),
            .fixedDayOfMonth(day: 1, shift: .none, alsoShiftOnWeekdays: []),
            .firstBankingDayOfMonth,
            .lastBankingDayOfMonth,
            .lastWeekdayOfMonth,
            .nthBankingDayOfMonth(n: 3),
            .nthWeekdayOfMonth(n: 2, weekday: .friday),
            .everyNthWeek(n: 2, startingOn: day(2026, 1, 2), shift: .previousBankingDay),
        ]
        for rule in rules {
            #expect(RuleDraft(rule).rule == rule)
        }
    }

    /// "Last weekday" is no longer offered, but the Kela benefit that uses it and
    /// rules saved earlier still resolve and survive the editor.
    @Test func lastWeekdayIsNoLongerOffered() {
        #expect(!RuleDraft.Kind.selectable.contains(.lastWeekday))
        #expect(RuleDraft.Kind.allCases.contains(.lastWeekday))
        #expect(RuleDraft(.lastWeekdayOfMonth).kind == .lastWeekday)
    }
}
