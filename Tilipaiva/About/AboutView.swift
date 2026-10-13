import SwiftUI

/// Information about the app, including links to the support and privacy policy pages.
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private let supportURL = URL(string: "https://tilipaiva.ruupert.fi/")!
    private let privacyPolicyURL = URL(string: "https://tilipaiva.ruupert.fi/privacy.html")!

    var body: some View {
        NavigationStack {
            List {
                LabeledContent("Version", value: version)

                Section {
                    Link(destination: supportURL) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    Link(destination: privacyPolicyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Tilipäivä"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    /// The app's marketing version and build number, e.g. "1.0 (1)".
    private var version: String {
        let info = Bundle.main.infoDictionary
        let shortVersion = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(shortVersion) (\(build))"
    }
}

#Preview {
    AboutView()
}
