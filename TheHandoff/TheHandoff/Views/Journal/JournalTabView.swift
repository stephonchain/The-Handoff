import SwiftUI
import SwiftData

struct JournalTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    @State private var selectedMode: JournalMode = .quickDump
    @State private var showingNewEntry = false
    @State private var searchText = ""

    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return entries
        }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode selector
                modeSelector
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                if entries.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .tint(Color(hex: "F59E0B"))
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher...")
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(mode: selectedMode)
        }
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        HStack(spacing: 8) {
            ForEach(JournalMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                    HapticManager.shared.impact(style: .light)
                }) {
                    VStack(spacing: 4) {
                        Text(mode.emoji)
                            .font(.title2)
                        Text(mode.title)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedMode == mode ? mode.color.opacity(0.15) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedMode == mode ? mode.color : .clear, lineWidth: 2)
                    )
                }
                .foregroundStyle(selectedMode == mode ? mode.color : .secondary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(selectedMode.emoji)
                .font(.system(size: 64))

            Text(selectedMode.emptyTitle)
                .font(.title3)
                .fontWeight(.semibold)

            Text(selectedMode.emptySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { showingNewEntry = true }) {
                Text("Commencer")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(selectedMode.color)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Journal List

    private var journalList: some View {
        List {
            ForEach(filteredEntries) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalEntryRow(entry: entry)
                }
            }
            .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Journal Entry Row

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.moodEmoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !entry.content.isEmpty {
                Text(entry.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !entry.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "F59E0B").opacity(0.1))
                            .foregroundStyle(Color(hex: "F59E0B"))
                            .clipShape(Capsule())
                    }
                    if entry.tags.count > 3 {
                        Text("+\(entry.tags.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Journal Mode

enum JournalMode: String, CaseIterable {
    case quickDump = "quick"
    case guided = "guided"
    case pride = "pride"

    var title: String {
        switch self {
        case .quickDump: return "Décharge"
        case .guided: return "Guidé"
        case .pride: return "Fierté"
        }
    }

    var emoji: String {
        switch self {
        case .quickDump: return "💨"
        case .guided: return "🧭"
        case .pride: return "🏆"
        }
    }

    var color: Color {
        switch self {
        case .quickDump: return Color(hex: "3B82F6")
        case .guided: return Color(hex: "8B5CF6")
        case .pride: return Color(hex: "F59E0B")
        }
    }

    var emptyTitle: String {
        switch self {
        case .quickDump: return "Vide ta tête"
        case .guided: return "Journal guidé"
        case .pride: return "Tes victoires"
        }
    }

    var emptySubtitle: String {
        switch self {
        case .quickDump: return "60 secondes pour tout lâcher. Pas besoin de réfléchir."
        case .guided: return "Des questions adaptées à ton état pour t'aider à y voir plus clair."
        case .pride: return "Les soignants oublient ce qu'ils gèrent. Note tes micro-victoires ici."
        }
    }
}
