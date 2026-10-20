import Foundation
import Testing
@testable import Tilipaiva

struct PaydayReminderScheduleTests {
    private let schedule = PaydayReminderSchedule()

    private var helsinki: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar
    }

    private func day(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0) -> Date {
        helsinki.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func source(_ name: String, _ rule: PaymentRule) -> PaymentSource {
        PaymentSource.salary(name: name, rule: rule)
    }

    @Test func noSourcesWantNoReminders() {
        #expect(schedule.reminders(for: [], onOrAfter: day(2026, 10, 1)).isEmpty)
    }

    @Test func paymentsThatShareADayShareAReminder() {
        let sources = [
            source("Palkka", .lastBankingDayOfMonth),
            source("Bonus", .lastBankingDayOfMonth),
        ]

        let reminders = schedule.reminders(for: sources, onOrAfter: day(2026, 10, 1))

        #expect(reminders.first?.day == day(2026, 10, 30))
        #expect(Set(reminders.first?.titles ?? []) == ["Palkka", "Bonus"])
    }

    @Test func theShiftedBankingDayIsTheDayReminded() {
        // 6 September 2026 is a Sunday, so the payment moves back to Friday the 4th.
        let sources = [source("Palkka", .fixedDayOfMonth(day: 6, shift: .previousBankingDay, alsoShiftOnWeekdays: []))]

        let reminders = schedule.reminders(for: sources, onOrAfter: day(2026, 9, 1))

        #expect(reminders.first?.day == day(2026, 9, 4))
    }

    @Test func aWeekIntervalSourceGivesEveryOneOfItsDays() {
        // 2 October 2026 is a Friday, so the series pays every Friday.
        let sources = [source("Palkka", .everyNthWeek(n: 1, startingOn: day(2026, 10, 2), shift: .previousBankingDay))]

        let reminders = schedule.reminders(for: sources, onOrAfter: day(2026, 10, 1))

        // The Friday of each week, filling the whole window.
        #expect(reminders.count == PaydayReminderSchedule.limit)
        #expect(reminders.prefix(5).map(\.day) == [
            day(2026, 10, 2),
            day(2026, 10, 9),
            day(2026, 10, 16),
            day(2026, 10, 23),
            day(2026, 10, 30),
        ])
        #expect(reminders.allSatisfy { $0.titles == ["Palkka"] })
    }

    @Test func aMorningThatHasGoneIsLeftOut() {
        let sources = [source("Palkka", .fixedDayOfMonth(day: 20, shift: .none, alsoShiftOnWeekdays: []))]

        // Before seven the day still counts; from seven on it does not, since the
        // system would not deliver a trigger set in the past.
        #expect(schedule.reminders(for: sources, onOrAfter: day(2026, 10, 20, 6)).first?.day == day(2026, 10, 20))
        #expect(schedule.reminders(for: sources, onOrAfter: day(2026, 10, 20, 7)).first?.day == day(2026, 11, 20))
        #expect(schedule.reminders(for: sources, onOrAfter: day(2026, 10, 20, 13)).first?.day == day(2026, 11, 20))
    }

    @Test func theWindowIsCappedAtTheLimit() {
        // Two weekly sources a day apart: forty distinct payment days before the
        // cap is applied.
        let sources = [
            source("Palkka", .everyNthWeek(n: 1, startingOn: day(2026, 10, 1), shift: .previousBankingDay)),
            source("Bonus", .everyNthWeek(n: 1, startingOn: day(2026, 10, 2), shift: .previousBankingDay)),
        ]

        let reminders = schedule.reminders(for: sources, onOrAfter: day(2026, 10, 1))

        #expect(reminders.count == PaydayReminderSchedule.limit)
        #expect(Set(reminders.map(\.day)).count == reminders.count)
        #expect(reminders.map(\.day) == reminders.map(\.day).sorted())
    }

    @Test func anIdentifierCarriesTheFinnishDay() {
        let sources = [source("Palkka", .lastBankingDayOfMonth)]

        let reminders = schedule.reminders(for: sources, onOrAfter: day(2026, 10, 1))

        #expect(reminders.first?.id == "payday.2026-10-30")
        #expect(reminders.first?.id.hasPrefix(PaydayReminderSchedule.identifierPrefix) == true)
    }

    @Test func theReminderArrivesOnTheFinnishMorning() {
        let paymentDay = day(2026, 10, 30)
        let moment = schedule.moment(for: paymentDay)
        let parts = helsinki.dateComponents([.year, .month, .day, .hour, .minute], from: moment)

        #expect(parts.year == 2026)
        #expect(parts.month == 10)
        #expect(parts.day == 30)
        #expect(parts.hour == PaydayReminderSchedule.hour)
        #expect(parts.minute == 0)
        #expect(BankingCalendar().dayCount(from: paymentDay, to: moment) == 0)
    }
}
