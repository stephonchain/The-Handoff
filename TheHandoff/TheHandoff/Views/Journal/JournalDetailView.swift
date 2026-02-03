import SwiftUI
import SwiftData

struct JournalDetailView: View {
    let entry: JournalEntry
    @Bindable var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(entry.moodEmoji)
                        .font(.system(size: 40))
                    Text(entry.title)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                HStack(spacing: 8) {
                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(entry.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "F59E0B").opacity(0.1))
                            .foregroundStyle(Color(hex: "F59E0B"))
                            .clipShape(Capsule())
                    }
                }

                Divider()

                Text(entry.content)
                    .font(.body)

                if !entry.highlights.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("journal_field_highlights")
                            .font(.headline)

                        ForEach(entry.highlights, id: \.self) { highlight in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(Color(hex: "F59E0B"))
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                Text(highlight)
                                    .font(.body)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEdit = true }) {
                        Label(String(localized: "button_edit"), systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label(String(localized: "button_delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            JournalEditView(entry: entry, viewModel: viewModel)
        }
        .alert(String(localized: "journal_delete_alert_title"), isPresented: $showingDeleteAlert) {
            Button(String(localized: "journal_delete_alert_cancel"), role: .cancel) {}
            Button(String(localized: "journal_delete_alert_confirm"), role: .destructive) {
                viewModel.deleteEntry(entry)
                dismiss()
            }
        } message: {
            Text("journal_delete_alert_message")
        }
    }
}
