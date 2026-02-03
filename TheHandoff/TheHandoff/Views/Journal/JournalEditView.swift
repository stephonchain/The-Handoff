import SwiftUI
import SwiftData

struct JournalEditView: View {
    let entry: JournalEntry
    @Bindable var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var content: String
    @State private var selectedTags: [String]
    @State private var highlights: [String]

    init(entry: JournalEntry, viewModel: JournalViewModel) {
        self.entry = entry
        self.viewModel = viewModel
        var h = entry.highlights
        while h.count < 3 { h.append("") }
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.content)
        _selectedTags = State(initialValue: entry.tags)
        _highlights = State(initialValue: h)
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("journal_field_title")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField(String(localized: "journal_field_title_placeholder"), text: $title)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    TagSelectorView(selectedTags: $selectedTags)

                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("journal_field_content_placeholder")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("journal_field_highlights")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: "F59E0B"))
                                    .frame(width: 6, height: 6)
                                TextField(String(localized: "journal_highlight_placeholder"), text: $highlights[index])
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle(String(localized: "journal_edit_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "journal_button_cancel")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "journal_button_save")) {
                        let filteredHighlights = highlights.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        viewModel.updateEntry(entry, title: title, content: content, tags: selectedTags, highlights: filteredHighlights)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Color(hex: "F59E0B"))
                    .disabled(!canSave)
                }
            }
        }
    }
}
