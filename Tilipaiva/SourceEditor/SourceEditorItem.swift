import Foundation

/// Identifies the source shown in the source editor sheet.
enum SourceEditorItem: Identifiable {
    case create
    case edit(PaymentSource)

    var id: String {
        switch self {
        case .create: "create"
        case let .edit(source): source.id.uuidString
        }
    }

    /// The source the editor starts from.
    var source: PaymentSource {
        switch self {
        case .create:
            PaymentSource(kind: .salary, rule: .fixedDayOfMonth(day: 15, shift: .previousBankingDay, alsoShiftOnWeekdays: []))
        case let .edit(source):
            source
        }
    }

    var isNew: Bool {
        if case .create = self { true } else { false }
    }
}
