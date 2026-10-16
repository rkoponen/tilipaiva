import SwiftUI

/// Edits a `PaymentRule` through the rule picker and its parameters.
struct RuleEditorView: View {
    @Binding var draft: RuleDraft

    @Environment(\.locale) private var locale

    var body: some View {
        Picker("Payday rule", selection: $draft.kind) {
            ForEach(kinds) { kind in
                Text(kind.title).tag(kind)
            }
        }

        switch draft.kind {
        case .dayOfMonth:
            Picker("Day", selection: $draft.day) {
                ForEach(1...31, id: \.self) { day in
                    Text(day, format: .number).tag(day)
                }
            }

            BankingDayShiftPicker(shift: $draft.shift)

        case .everyNthWeek:
            DatePicker("Next payment", selection: $draft.startingOn, displayedComponents: .date)

            Picker("Weeks between payments", selection: $draft.weeks) {
                ForEach(1...4, id: \.self) { weeks in
                    Text(weeks, format: .number).tag(weeks)
                }
            }

            BankingDayShiftPicker(shift: $draft.shift)

        case .nthBankingDay:
            Picker("Nth", selection: $draft.nth) {
                ForEach(1...5, id: \.self) { value in
                    Text(value, format: .number).tag(value)
                }
            }

        case .nthWeekday:
            Picker("Nth", selection: $draft.nth) {
                ForEach(1...5, id: \.self) { value in
                    Text(value, format: .number).tag(value)
                }
            }

            Picker("Weekday", selection: $draft.weekday) {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    Text(weekday.name(in: locale)).tag(weekday)
                }
            }

        case .firstBankingDay, .lastBankingDay, .lastWeekday:
            EmptyView()
        }
    }

    /// The picker options, plus the current rule's kind when the picker no longer
    /// offers it, so a rule saved earlier still shows what it is.
    private var kinds: [RuleDraft.Kind] {
        RuleDraft.Kind.selectable.contains(draft.kind)
            ? RuleDraft.Kind.selectable
            : RuleDraft.Kind.selectable + [draft.kind]
    }
}
