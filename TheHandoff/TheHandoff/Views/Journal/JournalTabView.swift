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
            ScrollView {
                VStack(spacing: 20) {
                    // Header with date
                    headerSection

                    // Mode selector cards
                    modeSelector

                    // Recent entries or empty state
                    if entries.isEmpty {
                        emptyState
                    } else {
                        recentEntriesSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
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

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Ton cerveau externe")
                .font(.title2)
                .fontWeight(.bold)

            Text("Choisis ton mode d'écriture")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        VStack(spacing: 12) {
            ForEach(JournalMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                    showingNewEntry = true
                    HapticManager.shared.impact(style: .medium)
                }) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(mode.color.opacity(0.15))
                                .frame(width: 52, height: 52)

                            Image(systemName: mode.icon)
                                .font(.title3)
                                .foregroundStyle(mode.color)
                        }

                        // Text
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(mode.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        // Time indicator
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(mode.duration)
                                .font(.caption)
                        }
                        .foregroundStyle(.tertiary)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedMode == mode ? mode.color.opacity(0.3) : .clear, lineWidth: 2)
                    )
                    .cardShadow()
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "3B82F6").opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "book.closed")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "3B82F6"))
            }

            VStack(spacing: 8) {
                Text("Ton journal est vide")
                    .font(.headline)

                Text("Commence par écrire ta première entrée.\nChoisis un mode ci-dessus.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
    }

    // MARK: - Recent Entries Section

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Entrées récentes")
                    .font(.headline)

                Spacer()

                if entries.count > 5 {
                    NavigationLink(destination: AllEntriesView()) {
                        Text("Tout voir")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                }
            }

            ForEach(filteredEntries.prefix(5)) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalEntryCard(entry: entry)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Journal Entry Card

struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Mode icon
                ZStack {
                    Circle()
                        .fill(entry.modeColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: entry.modeIcon)
                        .font(.body)
                        .foregroundStyle(entry.modeColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Mood indicator
                MoodIndicatorSmall(value: entry.moodValue)
            }

            if !entry.preview.isEmpty {
                Text(entry.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "F59E0B").opacity(0.1))
                                .foregroundStyle(Color(hex: "F59E0B"))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .cardShadow()
    }
}

// MARK: - Mood Indicator Small

struct MoodIndicatorSmall: View {
    let value: Int // 1-5

    var color: Color {
        switch value {
        case 1: return Color(hex: "EF4444")
        case 2: return Color(hex: "F59E0B")
        case 3: return Color(hex: "6B7280")
        case 4: return Color(hex: "10B981")
        case 5: return Color(hex: "10B981")
        default: return Color(hex: "6B7280")
        }
    }

    var icon: String {
        switch value {
        case 1: return "face.smiling"
        case 2: return "face.smiling"
        case 3: return "face.smiling"
        case 4: return "face.smiling.fill"
        case 5: return "face.smiling.fill"
        default: return "face.smiling"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)

            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
        }
    }
}

// MARK: - All Entries View

struct AllEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalEntryRow(entry: entry)
                }
            }
            .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
        .navigationTitle("Toutes les entrées")
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Journal Entry Row (for list)

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(entry.modeColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: entry.modeIcon)
                    .font(.body)
                    .foregroundStyle(entry.modeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !entry.tags.isEmpty {
                        Text("• \(entry.tags.first ?? "")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Journal Mode

enum JournalMode: String, CaseIterable {
    case quickDump = "quick"
    case guided = "guided"
    case pride = "pride"

    var title: String {
        switch self {
        case .quickDump: return "Décharge rapide"
        case .guided: return "Journal guidé"
        case .pride: return "Journal de fierté"
        }
    }

    var subtitle: String {
        switch self {
        case .quickDump: return "Vide ta tête sans réfléchir"
        case .guided: return "Questions adaptées à ton état"
        case .pride: return "Note tes micro-victoires"
        }
    }

    var icon: String {
        switch self {
        case .quickDump: return "wind"
        case .guided: return "list.bullet.clipboard"
        case .pride: return "trophy.fill"
        }
    }

    var duration: String {
        switch self {
        case .quickDump: return "60s"
        case .guided: return "3 min"
        case .pride: return "2 min"
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

// MARK: - JournalEntry Extensions

extension JournalEntry {
    var modeColor: Color {
        if title.contains("Décharge") || title.contains("rapide") {
            return Color(hex: "3B82F6")
        } else if title.contains("guidé") || title.contains("Guidé") {
            return Color(hex: "8B5CF6")
        } else if title.contains("fierté") || title.contains("Fierté") {
            return Color(hex: "F59E0B")
        }
        return Color(hex: "6B7280")
    }

    var modeIcon: String {
        if title.contains("Décharge") || title.contains("rapide") {
            return "wind"
        } else if title.contains("guidé") || title.contains("Guidé") {
            return "list.bullet.clipboard"
        } else if title.contains("fierté") || title.contains("Fierté") {
            return "trophy.fill"
        }
        return "book.fill"
    }

    var moodValue: Int {
        switch moodEmoji {
        case "😫": return 1
        case "😔": return 2
        case "😐": return 3
        case "🙂": return 4
        case "😊": return 5
        default: return 3
        }
    }
}
