import SwiftUI

/// What the home screen shows before anything is tracked.
struct HomeEmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No payment sources yet",
            systemImage: "calendar.badge.plus",
            description: Text("Add a salary or Kela benefit to see your next payday.")
        )
    }
}

#Preview {
    HomeEmptyStateView()
}
