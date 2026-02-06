import SwiftUI
import SwiftData

struct JournalTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    @State private var showingNewEntry = false
    @State private var selectedMode: JournalMode = .quickDump
    @State private var searchText = ""

    // Journal streak
    private var journalStreak: (current: Int, longest: Int) {
        calculateStreak()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick Actions
                    quickActionsSection

                    // Streak Section
                    streakSection

                    // Daily Prompt
                    dailyPromptSection

                    // This Day - Memories
                    if !memoriesFromThisDay.isEmpty {
                        thisDaySection
                    }

                    // Recent Entries
                    if !entries.isEmpty {
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
                    Button(action: {
                        selectedMode = .quickDump
                        showingNewEntry = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .tint(Color(hex: "3B82F6"))
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher...")
        }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(mode: selectedMode)
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Démarrage rapide")
                .font(.headline)

            Text("Crée une entrée avec l'un des modes suivants :")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                ForEach(JournalMode.allCases, id: \.self) { mode in
                    Button(action: {
                        selectedMode = mode
                        showingNewEntry = true
                        HapticManager.shared.impact(style: .medium)
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .frame(width: 52, height: 52)

                                Image(systemName: mode.icon)
                                    .font(.title3)
                                    .foregroundStyle(mode.color)
                            }

                            Text(mode.shortTitle)
                                .font(.caption2)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Série")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllEntriesView()) {
                    Text("Voir plus")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "3B82F6"))
                }
            }

            VStack(spacing: 16) {
                // Stats row
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Série actuelle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(journalStreak.current)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                        .frame(height: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Série la plus longue")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(journalStreak.longest)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                }

                // 7-day circles
                HStack(spacing: 0) {
                    ForEach(last7Days, id: \.self) { date in
                        let hasEntry = hasEntryOnDate(date)
                        let isToday = Calendar.current.isDateInToday(date)

                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .stroke(hasEntry ? Color(hex: "3B82F6") : Color(.systemGray4), lineWidth: 2)
                                    .frame(width: 36, height: 36)

                                if hasEntry {
                                    Circle()
                                        .fill(Color(hex: "3B82F6"))
                                        .frame(width: 28, height: 28)

                                    Image(systemName: "checkmark")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                }
                            }

                            Text(dayNumber(date))
                                .font(.caption2)
                                .foregroundStyle(isToday ? Color(hex: "3B82F6") : .secondary)

                            if isToday {
                                Circle()
                                    .fill(Color(hex: "3B82F6"))
                                    .frame(width: 4, height: 4)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
    }

    // MARK: - Daily Prompt Section

    private var dailyPromptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Invite du jour")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Refresh prompt
                    HapticManager.shared.impact(style: .light)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button(action: {
                selectedMode = .guided
                showingNewEntry = true
                HapticManager.shared.impact(style: .medium)
            }) {
                Text(dailyPrompt)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }

    private var dailyPrompt: String {
        let prompts = [
            "Qu'est-ce qui t'a donné de l'énergie aujourd'hui ?",
            "Quel moment t'a fait sourire cette semaine ?",
            "De quoi es-tu fier(e) récemment ?",
            "Qu'as-tu appris sur toi dernièrement ?",
            "Quel patient t'a marqué(e) positivement ?",
            "Comment as-tu pris soin de toi aujourd'hui ?",
            "Quelle petite victoire as-tu eu au travail ?",
            "Qu'est-ce qui te motive à continuer ?",
            "Quel collègue t'a aidé(e) récemment ?",
            "Qu'aimerais-tu améliorer demain ?"
        ]
        // Use day of year to rotate prompts
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return prompts[dayOfYear % prompts.count]
    }

    // MARK: - This Day Section (Memories)

    private var memoriesFromThisDay: [JournalEntry] {
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.month, .day], from: today)

        return entries.filter { entry in
            let entryComponents = calendar.dateComponents([.month, .day], from: entry.createdAt)
            let isSameDay = entryComponents.month == todayComponents.month && entryComponents.day == todayComponents.day
            let isNotThisYear = !calendar.isDate(entry.createdAt, equalTo: today, toGranularity: .year)
            return isSameDay && isNotThisYear
        }
    }

    private var thisDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ce jour")
                    .font(.headline)

                Text(Date(), format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())

                Spacer()

                Text("Voir plus")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "3B82F6"))
            }

            Text("Tes souvenirs de ce jour les années passées")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(memoriesFromThisDay.prefix(5)) { entry in
                        NavigationLink(destination: JournalDetailView(entry: entry)) {
                            MemoryCard(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Recent Entries Section

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Entrées récentes")
                    .font(.headline)
                Spacer()
                if entries.count > 5 {
                    NavigationLink(destination: AllEntriesView()) {
                        Text("Tout voir")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "3B82F6"))
                    }
                }
            }

            // Group by month
            let groupedEntries = groupEntriesByMonth(Array(entries.prefix(10)))

            ForEach(groupedEntries, id: \.month) { group in
                VStack(alignment: .leading, spacing: 0) {
                    // Month header
                    Text(group.month)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)

                    // Entries
                    VStack(spacing: 0) {
                        ForEach(group.entries) { entry in
                            NavigationLink(destination: JournalDetailView(entry: entry)) {
                                DayOneStyleEntryRow(entry: entry)
                            }
                            .buttonStyle(.plain)

                            if entry.id != group.entries.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Helper Functions

    private var last7Days: [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -6 + offset, to: Date())
        }
    }

    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func hasEntryOnDate(_ date: Date) -> Bool {
        entries.contains { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
    }

    private func calculateStreak() -> (current: Int, longest: Int) {
        let calendar = Calendar.current
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Check if there's an entry today
        if hasEntryOnDate(checkDate) {
            currentStreak = 1
            tempStreak = 1
        }

        // Go backwards to count streak
        while true {
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }

            if hasEntryOnDate(previousDate) {
                if currentStreak > 0 || hasEntryOnDate(calendar.startOfDay(for: Date())) {
                    currentStreak += 1
                }
                tempStreak += 1
            } else {
                longestStreak = max(longestStreak, tempStreak)
                if currentStreak > 0 {
                    break
                }
                tempStreak = 0
            }

            checkDate = previousDate

            // Safety limit
            if calendar.dateComponents([.day], from: previousDate, to: Date()).day ?? 0 > 365 {
                break
            }
        }

        longestStreak = max(longestStreak, tempStreak, currentStreak)
        return (currentStreak, longestStreak)
    }

    private func groupEntriesByMonth(_ entries: [JournalEntry]) -> [MonthGroup] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")

        var groups: [String: [JournalEntry]] = [:]
        var orderedMonths: [String] = []

        for entry in entries {
            let monthKey = formatter.string(from: entry.createdAt)
            if groups[monthKey] == nil {
                groups[monthKey] = []
                orderedMonths.append(monthKey)
            }
            groups[monthKey]?.append(entry)
        }

        return orderedMonths.compactMap { month in
            guard let entries = groups[month] else { return nil }
            return MonthGroup(month: month, entries: entries)
        }
    }
}

// MARK: - Month Group

struct MonthGroup {
    let month: String
    let entries: [JournalEntry]
}

// MARK: - Day One Style Entry Row

struct DayOneStyleEntryRow: View {
    let entry: JournalEntry

    private var dayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "E"
        f.locale = Locale(identifier: "fr_FR")
        return f
    }

    private var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "dd"
        return f.string(from: entry.createdAt)
    }

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: entry.createdAt)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Date column
            VStack(spacing: 2) {
                Text(dayFormatter.string(from: entry.createdAt).uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text(dayNumber)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(width: 44)

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Spacer()

                    // Mood indicator
                    Image(systemName: entry.modeIcon)
                        .font(.caption)
                        .foregroundStyle(entry.modeColor)
                }

                Text(timeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !entry.preview.isEmpty {
                    Text(entry.preview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if !entry.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "3B82F6").opacity(0.1))
                                .foregroundStyle(Color(hex: "3B82F6"))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

// MARK: - Memory Card

struct MemoryCard: View {
    let entry: JournalEntry

    private var yearString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: entry.createdAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Year badge
            Text(yearString)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "3B82F6"))
                .clipShape(Capsule())

            Text(entry.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            if !entry.preview.isEmpty {
                Text(entry.preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .frame(width: 160, height: 120, alignment: .topLeading)
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .cardShadow()
    }
}

// MARK: - All Entries View

struct AllEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
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
        List {
            ForEach(filteredEntries) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalEntryRow(entry: entry)
                }
            }
            .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
        .navigationTitle("Toutes les entrées")
        .searchable(text: $searchText, prompt: "Rechercher...")
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
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

    var shortTitle: String {
        switch self {
        case .quickDump: return "Décharge"
        case .guided: return "Guidé"
        case .pride: return "Fierté"
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
