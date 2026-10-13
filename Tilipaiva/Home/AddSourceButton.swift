import SwiftUI

/// The floating button that adds a new payment source.
struct AddSourceButton: View {
    var action: () -> Void

    var body: some View {
        Button("Add Source", systemImage: "plus", action: action)
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
    }
}
