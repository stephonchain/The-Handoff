import SwiftUI
import SwiftData

struct NewJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var moodEmoji = "😊"
    @State private var selectedTags: [String] = []
    @State private var highlights: [String] = ["", "", ""]
    @State private var showingCancelAlert = false

    let moodOptions = ["😊", "😔", "😌", "😰", "💪", "😴", "😤", "🙏"]

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasContent: Bool {
        !title.isEmpty || !content.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("journal_field_title")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField(String(localized: "journal_field_title_placeholder"), text: $title)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Mood
                    VStack(alignment: .leading, spacing: 8) {
                        Text("journal_field_mood")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        HStack(spacing: 12) {
                            ForEach(moodOptions, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(moodEmoji == emoji ? Color(hex: "F59E0B").opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(moodEmoji == emoji ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        moodEmoji = emoji
                                        HapticManager.shared.impact(style: .light)
                                    }
                            }
                        }
                    }

                    // Tags
                    TagSelectorView(selectedTags: $selectedTags)

                    // Content
                    VStack(alignment: .leading, spacing: 8) {
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
                    }

                    // Highlights
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
            .navigationTitle(String(localized: "journal_new_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "journal_button_cancel")) {
                        if hasContent {
                            showingCancelAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "journal_button_save")) {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .tint(Color(hex: "F59E0B"))
                    .disabled(!canSave)
                }
            }
            .alert(String(localized: "journal_button_cancel"), isPresented: $showingCancelAlert) {
                Button(String(localized: "journal_delete_alert_cancel"), role: .cancel) {}
                Button(String(localized: "journal_delete_alert_confirm"), role: .destructive) { dismiss() }
            } message: {
                Text("Discard this entry?")
            }
        }
    }

    private func saveEntry() {
        let vm = JournalViewModel(modelContext: modelContext)
        let filteredHighlights = highlights.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        vm.createEntry(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content,
            moodEmoji: moodEmoji,
            tags: selectedTags,
            highlights: filteredHighlights
        )
        dismiss()
    }
}
