import SwiftUI

/// The days-until-payday phrase, e.g. "Today!" or "12 days".
struct DaysUntilText: View {
    let days: Int

    var body: some View {
        if days == 0 {
            Text("Today!")
        } else {
            Text("\(days) days")
        }
    }
}

#Preview {
    VStack {
        DaysUntilText(days: 0)
        DaysUntilText(days: 12)
    }
    .font(.title)
}
