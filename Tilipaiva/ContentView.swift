import SwiftUI

struct ContentView: View {
    @State private var model = PaymentSourcesModel()
    @State private var editorItem: SourceEditorItem?
    @State private var isShowingAbout = false

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        HomeView(model: model, onSelect: edit, onAbout: showAbout)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                AddSourceButton(action: addSource)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .background { PaymentBackground().ignoresSafeArea() }
            .sheet(isPresented: $isShowingAbout) {
                AboutView()
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

    private func showAbout() {
        isShowingAbout = true
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
