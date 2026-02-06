import SwiftUI
import SwiftData

struct NewJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: JournalMode

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var moodEmoji: String = "😊"
    @State private var selectedTags: [String] = []
    @State private var highlights: [String] = []
    @State private var newHighlight: String = ""

    // Guided mode questions
    @State private var guidedAnswers: [String: String] = [:]

    private var guidedQuestions: [String] {
        // TODO: Base questions on today's check-in state
        return [
            "Qu'est-ce qui t'a le plus marqué aujourd'hui ?",
            "Comment as-tu géré les moments difficiles ?",
            "Qu'aurais-tu fait différemment ?"
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mode header
                    modeHeader

                    switch mode {
                    case .quickDump:
                        quickDumpContent
                    case .guided:
                        guidedContent
                    case .pride:
                        prideContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(mode.color)
                    .disabled(content.isEmpty && highlights.isEmpty && guidedAnswers.isEmpty)
                }
            }
        }
    }

    // MARK: - Mode Header

    private var modeHeader: some View {
        VStack(spacing: 8) {
            Text(mode.emoji)
                .font(.system(size: 40))
            Text(mode.emptySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }

    // MARK: - Quick Dump Mode

    private var quickDumpContent: some View {
        VStack(spacing: 16) {
            // Big text field
            VStack(alignment: .leading, spacing: 8) {
                Text("Vide ta tête...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }

            // Mood selector
            moodSelector

            // Quick tags
            tagSelector
        }
    }

    // MARK: - Guided Mode

    private var guidedContent: some View {
        VStack(spacing: 20) {
            ForEach(guidedQuestions, id: \.self) { question in
                VStack(alignment: .leading, spacing: 8) {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextField("Ta réponse...", text: Binding(
                        get: { guidedAnswers[question] ?? "" },
                        set: { guidedAnswers[question] = $0 }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }

            // Mood selector
            moodSelector
        }
    }

    // MARK: - Pride Mode

    private var prideContent: some View {
        VStack(spacing: 20) {
            // Highlights list
            VStack(alignment: .leading, spacing: 12) {
                Text("Mes micro-victoires du jour")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(highlights.indices, id: \.self) { index in
                    HStack {
                        Text("🏆")
                        Text(highlights[index])
                            .font(.body)
                        Spacer()
                        Button(action: { highlights.remove(at: index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "F59E0B").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Add new highlight
                HStack {
                    TextField("Ajouter une fierté...", text: $newHighlight)
                        .onSubmit {
                            addHighlight()
                        }

                    Button(action: addHighlight) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                    .disabled(newHighlight.isEmpty)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            // Suggestions
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggestions")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(prideSuggestions, id: \.self) { suggestion in
                        Button(action: {
                            newHighlight = suggestion
                            addHighlight()
                        }) {
                            Text(suggestion)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }

            // Optional note
            VStack(alignment: .leading, spacing: 8) {
                Text("Note (optionnel)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $content)
                    .frame(minHeight: 80)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
    }

    private var prideSuggestions: [String] {
        [
            "J'ai aidé un patient difficile",
            "J'ai gardé mon calme",
            "J'ai pris ma pause",
            "J'ai bien communiqué avec l'équipe",
            "J'ai appris quelque chose",
            "J'ai fait preuve de patience"
        ]
    }

    private func addHighlight() {
        guard !newHighlight.isEmpty else { return }
        highlights.append(newHighlight)
        newHighlight = ""
        HapticManager.shared.impact(style: .light)
    }

    // MARK: - Common Components

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Comment tu te sens ?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(["😫", "😔", "😐", "🙂", "😊"], id: \.self) { emoji in
                    Button(action: {
                        moodEmoji = emoji
                        HapticManager.shared.impact(style: .light)
                    }) {
                        Text(emoji)
                            .font(.title)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(moodEmoji == emoji ? mode.color.opacity(0.2) : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(moodEmoji == emoji ? mode.color : .clear, lineWidth: 2)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var tagSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(availableTags, id: \.self) { tag in
                    Button(action: { toggleTag(tag) }) {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedTags.contains(tag)
                                    ? mode.color.opacity(0.15)
                                    : Color(.systemGray6)
                            )
                            .foregroundStyle(
                                selectedTags.contains(tag)
                                    ? mode.color
                                    : .primary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedTags.contains(tag) ? mode.color : .clear, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var availableTags: [String] {
        ["Shift difficile", "Belle rencontre", "Apprentissage", "Équipe géniale",
         "Fatigue", "Fierté", "Questionnement", "Urgence", "Décès", "Rétablissement"]
    }

    private func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
        HapticManager.shared.impact(style: .light)
    }

    // MARK: - Save

    private func saveEntry() {
        let entryTitle: String
        let entryContent: String

        switch mode {
        case .quickDump:
            entryTitle = "Décharge rapide"
            entryContent = content
        case .guided:
            entryTitle = "Journal guidé"
            entryContent = guidedQuestions.compactMap { question in
                guard let answer = guidedAnswers[question], !answer.isEmpty else { return nil }
                return "**\(question)**\n\(answer)"
            }.joined(separator: "\n\n")
        case .pride:
            entryTitle = "Mes fiertés"
            let highlightsText = highlights.map { "🏆 \($0)" }.joined(separator: "\n")
            entryContent = content.isEmpty ? highlightsText : "\(highlightsText)\n\n\(content)"
        }

        let entry = JournalEntry(title: entryTitle, content: entryContent, moodEmoji: moodEmoji)
        entry.tags = selectedTags
        entry.highlights = highlights

        modelContext.insert(entry)
        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
    }
}
