import SwiftUI

/// The required reminder that Kela payment days are estimates.
struct PaymentDisclaimer: View {
    var body: some View {
        Text("Payment days are estimates. Check the up-to-date information in OmaKela.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PaymentDisclaimer()
        .padding()
}
