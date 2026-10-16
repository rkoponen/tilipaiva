import Testing
@testable import Tilipaiva

@MainActor
struct SourceEditorItemTests {
    /// A new salary pays on the last banking day of the month, the most common
    /// Finnish payday.
    @Test func aNewSalaryDefaultsToTheLastBankingDay() {
        #expect(SourceEditorItem.create.source.rule == .lastBankingDayOfMonth)
    }

    /// Editing keeps the source's existing rule untouched.
    @Test func editingKeepsTheExistingRule() {
        let source = PaymentSource.salary(name: "Palkka", rule: .lastBankingDayOfMonth)
        #expect(SourceEditorItem.edit(source).source.rule == .lastBankingDayOfMonth)
    }
}
