import SwiftUI

/// Adds or edits a payment source.
struct SourceEditorView: View {
    let item: SourceEditorItem
    var onSave: (PaymentSource) -> Void
    var onDelete: (PaymentSource) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @State private var draft: SourceDraft
    @State private var isConfirmingRemoval = false

    init(
        item: SourceEditorItem,
        onSave: @escaping (PaymentSource) -> Void,
        onDelete: @escaping (PaymentSource) -> Void
    ) {
        self.item = item
        self.onSave = onSave
        self.onDelete = onDelete
        _draft = State(initialValue: SourceDraft(item.source))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Kind", selection: $draft.kind) {
                        Text("Salary").tag(PaymentSource.Kind.salary)
                        Text("Benefit").tag(PaymentSource.Kind.benefit)
                    }
                }

                if draft.kind == .benefit {
                    Section {
                        Picker("Kela benefit", selection: $draft.benefitID) {
                            ForEach(BenefitCatalog.bundled.benefits) { benefit in
                                Text(benefit.name.value(for: locale)).tag(benefit.id as Benefit.ID?)
                            }
                        }
                    }
                } else {
                    Section {
                        TextField("Name", text: $draft.name)
                    }

                    Section("Payday rule") {
                        RuleEditorView(draft: $draft.rule)
                    }
                }

                Section("Next payments") {
                    PaymentPreviewView(rule: draft.effectiveRule)
                }

                if draft.kind == .benefit {
                    Section {
                        PaymentDisclaimer()
                    }
                }

                if !item.isNew {
                    Section {
                        Button("Remove Source", role: .destructive, action: confirmRemoval)
                            .confirmationDialog(
                                "Remove this source?",
                                isPresented: $isConfirmingRemoval,
                                titleVisibility: .visible
                            ) {
                                Button("Remove Source", role: .destructive, action: remove)
                                Button("Cancel", role: .cancel) {}
                            }
                    }
                }
            }
            .navigationTitle(item.isNew ? Text("Add Source") : Text("Edit Source"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
            .onChange(of: draft.kind) { _, kind in
                selectFirstBenefitIfNeeded(for: kind)
            }
        }
    }

    private func selectFirstBenefitIfNeeded(for kind: PaymentSource.Kind) {
        guard kind == .benefit, draft.benefitID == nil else { return }
        draft.benefitID = BenefitCatalog.bundled.benefits.first?.id
    }

    private func confirmRemoval() {
        isConfirmingRemoval = true
    }

    private func remove() {
        onDelete(item.source)
        dismiss()
    }

    private func save() {
        onSave(draft.source)
        dismiss()
    }
}

#Preview {
    SourceEditorView(item: .create, onSave: { _ in }, onDelete: { _ in })
}
