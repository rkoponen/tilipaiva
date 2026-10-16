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
    ///
    /// A new salary pays on the last banking day of the month, the most common
    /// Finnish payday. That is also what "the last day of the month" becomes
    /// once Finnish law moves a weekend or holiday payday to the day before.
    var source: PaymentSource {
        switch self {
        case .create:
            PaymentSource(kind: .salary, rule: .lastBankingDayOfMonth)
        case let .edit(source):
            source
        }
    }

    var isNew: Bool {
        if case .create = self { true } else { false }
    }
}
