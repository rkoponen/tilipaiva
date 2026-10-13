import Foundation

/// How a payment date is adjusted when it does not fall on a banking day.
nonisolated enum BankingDayShift: String, Codable, CaseIterable, Sendable {
    /// The date is used as is.
    case none

    /// The payment moves to the previous banking day.
    case previousBankingDay

    /// The payment moves to the next banking day.
    case nextBankingDay
}
