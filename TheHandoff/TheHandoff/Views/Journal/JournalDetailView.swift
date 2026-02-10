import SwiftUI
import SwiftData

struct JournalDetailView: View {
    let entry: JournalEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text(entry.moodEmoji)
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(entry.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Tags
                if !entry.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(hex: "F59E0B").opacity(0.1))
                                .foregroundStyle(Color(hex: "F59E0B"))
                                .clipShape(Capsule())
                        }
                    }
                }

                Divider()

                // Content
                Text(entry.content)
                    .font(.body)

                // Highlights
                if !entry.highlights.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mes fiertés")
                            .font(.headline)

                        ForEach(entry.highlights, id: \.self) { highlight in
                            HStack(alignment: .top, spacing: 8) {
                                Text("🏆")
                                Text(highlight)
                                    .font(.body)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "F59E0B").opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEdit = true }) {
                        Label("Modifier", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditJournalEntryView(entry: entry)
        }
        .alert("Supprimer cette entrée ?", isPresented: $showingDeleteAlert) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                modelContext.delete(entry)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }
}

// MARK: - Edit View

struct EditJournalEntryView: View {
    let entry: JournalEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var moodEmoji: String = "😊"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Titre")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("Titre de l'entrée", text: $title)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Mood
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Humeur")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach(["😫", "😔", "😐", "🙂", "😊"], id: \.self) { emoji in
                                Button(action: { moodEmoji = emoji }) {
                                    Text(emoji)
                                        .font(.title)
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(moodEmoji == emoji ? Color(hex: "F59E0B").opacity(0.2) : Color.clear)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(moodEmoji == emoji ? Color(hex: "F59E0B") : .clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }

                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contenu")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .onAppear {
                title = entry.title
                content = entry.content
                moodEmoji = entry.moodEmoji
            }
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.content = content
        entry.moodEmoji = moodEmoji
        entry.modifiedAt = Date()
        try? modelContext.save()
    }
}
