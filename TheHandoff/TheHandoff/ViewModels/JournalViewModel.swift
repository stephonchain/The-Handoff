import SwiftUI
import SwiftData

@Observable
final class JournalViewModel {
    var entries: [JournalEntry] = []
    var isLoading = false
    var searchQuery = ""

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var filteredEntries: [JournalEntry] {
        if searchQuery.isEmpty {
            return entries
        }
        return entries.filter { entry in
            entry.title.localizedCaseInsensitiveContains(searchQuery) ||
            entry.content.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    @MainActor
    func loadEntries() async {
        isLoading = true
        defer { isLoading = false }

        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }

    func createEntry(title: String, content: String, moodEmoji: String, tags: [String], highlights: [String], shift: Shift? = nil) {
        let entry = JournalEntry(title: title, content: content, moodEmoji: moodEmoji)
        entry.tags = tags
        entry.highlights = highlights
        entry.shift = shift

        modelContext.insert(entry)
        try? modelContext.save()

        Task { await loadEntries() }
        HapticManager.shared.notification(type: .success)
    }

    func updateEntry(_ entry: JournalEntry, title: String, content: String, tags: [String], highlights: [String]) {
        entry.title = title
        entry.content = content
        entry.tags = tags
        entry.highlights = highlights
        entry.modifiedAt = Date()

        try? modelContext.save()
        Task { await loadEntries() }
    }

    func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        Task { await loadEntries() }
    }
}
