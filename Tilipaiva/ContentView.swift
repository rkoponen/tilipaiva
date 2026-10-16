import SwiftUI

struct ContentView: View {
    @State private var model = PaymentSourcesModel()
    @State private var editorItem: SourceEditorItem?

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(model: model, onSelect: edit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        AddSourceButton(action: addSource)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    // The tab carries its own background: a TabView draws over
                    // one applied to the TabView itself.
                    .background { PaymentBackground().ignoresSafeArea() }
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .sheet(item: $editorItem) { item in
            SourceEditorView(item: item, onSave: model.upsert, onDelete: model.delete)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
            }
        }
    }

    private func addSource() {
        editorItem = .create
    }

    private func edit(_ source: PaymentSource) {
        editorItem = .edit(source)
    }
}

#Preview {
    ContentView()
}
