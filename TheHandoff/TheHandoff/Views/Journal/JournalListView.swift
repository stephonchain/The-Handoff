import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: JournalViewModel?
    @State private var showingNewJournal = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.filteredEntries.isEmpty && !vm.isLoading {
                        EmptyStateView(
                            icon: "book.closed",
                            title: String(localized: "journal_empty_title"),
                            subtitle: String(localized: "journal_empty_subtitle"),
                            buttonTitle: String(localized: "journal_empty_button"),
                            buttonAction: { showingNewJournal = true }
                        )
                    } else {
                        List {
                            ForEach(vm.filteredEntries) { entry in
                                NavigationLink(destination: JournalDetailView(entry: entry, viewModel: vm)) {
                                    JournalEntryRow(entry: entry)
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    vm.deleteEntry(vm.filteredEntries[index])
                                }
                            }
                        }
                        .listStyle(.plain)
                        .searchable(text: $searchText, prompt: String(localized: "journal_search_placeholder"))
                        .onChange(of: searchText) { _, newValue in
                            vm.searchQuery = newValue
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(String(localized: "journal_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewJournal = true }) {
                        Image(systemName: "plus")
                    }
                    .tint(Color(hex: "F59E0B"))
                }
            }
            .sheet(isPresented: $showingNewJournal) {
                NewJournalView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = JournalViewModel(modelContext: modelContext)
            }
            await viewModel?.loadEntries()
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 12) {
            Text(entry.moodEmoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(entry.preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(entry.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if !entry.tags.isEmpty {
                        Text(entry.tags.prefix(2).joined(separator: ", "))
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
