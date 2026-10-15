import Testing
@testable import Tilipaiva

@MainActor
struct SourceEditorItemTests {
    /// A new salary shifts to the previous banking day, as Finnish law requires
    /// for an agreed payday that falls on a non-banking day.
    @Test func aNewSalaryShiftsToThePreviousBankingDay() {
        #expect(SourceEditorItem.create.source.rule
            == .fixedDayOfMonth(day: 15, shift: .previousBankingDay, alsoShiftOnWeekdays: []))
    }

    /// Editing keeps the source's existing rule untouched.
    @Test func editingKeepsTheExistingRule() {
        let source = PaymentSource.salary(name: "Palkka", rule: .lastBankingDayOfMonth)
        #expect(SourceEditorItem.edit(source).source.rule == .lastBankingDayOfMonth)
    }
}
