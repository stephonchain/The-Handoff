import SwiftUI
import SwiftData

struct VacationManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: VacationViewModel?
    @State private var showingAddSheet = false
    @State private var editingVacation: Vacation?

    var body: some View {
        Group {
            if let vm = viewModel {
                List {
                    if !vm.upcomingVacations.isEmpty {
                        Section(String(localized: "timeoff_upcoming")) {
                            ForEach(vm.upcomingVacations) { vacation in
                                VacationRow(vacation: vacation)
                                    .onTapGesture { editingVacation = vacation }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    vm.deleteVacation(vm.upcomingVacations[index])
                                }
                            }
                        }
                    }

                    if !vm.pastVacations.isEmpty {
                        Section(String(localized: "timeoff_past")) {
                            ForEach(vm.pastVacations) { vacation in
                                VacationRow(vacation: vacation)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    vm.deleteVacation(vm.pastVacations[index])
                                }
                            }
                        }
                    }

                    if vm.vacations.isEmpty {
                        EmptyStateView(
                            icon: "calendar",
                            title: "No time off yet",
                            subtitle: "Add your upcoming time off to start the countdown"
                        )
                        .listRowBackground(Color.clear)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(String(localized: "timeoff_title"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
                .tint(Color(hex: "F59E0B"))
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            VacationEditSheet(viewModel: viewModel)
        }
        .sheet(item: $editingVacation) { vacation in
            VacationEditSheet(viewModel: viewModel, vacation: vacation)
        }
        .task {
            if viewModel == nil {
                viewModel = VacationViewModel(modelContext: modelContext)
            }
            await viewModel?.loadVacations()
        }
    }
}

struct VacationRow: View {
    let vacation: Vacation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: vacation.type.icon)
                    .foregroundStyle(Color(hex: "F59E0B"))
                Text(vacation.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            Text(vacation.dateRangeString)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(vacation.daysCount) days")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

struct VacationEditSheet: View {
    var viewModel: VacationViewModel?
    var vacation: Vacation?
    @Environment(\.dismiss) private var dismiss
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var type: VacationType
    @State private var customName: String

    init(viewModel: VacationViewModel?, vacation: Vacation? = nil) {
        self.viewModel = viewModel
        self.vacation = vacation
        _startDate = State(initialValue: vacation?.startDate ?? Date())
        _endDate = State(initialValue: vacation?.endDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
        _type = State(initialValue: vacation?.type ?? .vacation)
        _customName = State(initialValue: vacation?.customName ?? "")
    }

    var isValid: Bool { endDate > startDate }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "timeoff_type"), selection: $type) {
                        ForEach(VacationType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }

                    TextField(String(localized: "timeoff_custom_name"), text: $customName)
                }

                Section {
                    DatePicker(String(localized: "timeoff_setup_start"), selection: $startDate, displayedComponents: .date)
                    DatePicker(String(localized: "timeoff_setup_end"), selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle(vacation == nil ? String(localized: "timeoff_add_title") : String(localized: "timeoff_edit_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "button_cancel")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "button_save")) {
                        if let existing = vacation {
                            viewModel?.updateVacation(existing, startDate: startDate, endDate: endDate, type: type, customName: customName.isEmpty ? nil : customName)
                        } else {
                            viewModel?.addVacation(startDate: startDate, endDate: endDate, type: type, customName: customName.isEmpty ? nil : customName)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Color(hex: "F59E0B"))
                    .disabled(!isValid)
                }
            }
        }
    }
}
