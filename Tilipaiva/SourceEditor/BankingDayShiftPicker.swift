import SwiftUI

/// Picks how a payment date moves when it does not fall on a banking day.
struct BankingDayShiftPicker: View {
    @Binding var shift: BankingDayShift

    var body: some View {
        Picker("Adjustment", selection: $shift) {
            Text("None").tag(BankingDayShift.none)
            Text("Previous banking day").tag(BankingDayShift.previousBankingDay)
            Text("Next banking day").tag(BankingDayShift.nextBankingDay)
        }
    }
}

#Preview {
    @Previewable @State var shift: BankingDayShift = .previousBankingDay
    Form {
        BankingDayShiftPicker(shift: $shift)
    }
}
