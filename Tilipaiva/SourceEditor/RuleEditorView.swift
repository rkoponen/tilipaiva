import SwiftUI

/// Edits a `PaymentRule` through the rule picker and its parameters.
struct RuleEditorView: View {
    @Binding var draft: RuleDraft

    @Environment(\.locale) private var locale

    var body: some View {
        Picker("Payday rule", selection: $draft.kind) {
            ForEach(RuleDraft.Kind.allCases) { kind in
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

            Picker("Adjustment", selection: $draft.shift) {
                Text("None").tag(BankingDayShift.none)
                Text("Previous banking day").tag(BankingDayShift.previousBankingDay)
                Text("Next banking day").tag(BankingDayShift.nextBankingDay)
            }

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
}
