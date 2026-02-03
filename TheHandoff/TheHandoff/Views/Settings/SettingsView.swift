import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var vacations: [Vacation]
    @State private var showingNameEdit = false
    @State private var editedName = ""

    var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "settings_profile")) {
                    Button(action: {
                        editedName = profile?.firstName ?? ""
                        showingNameEdit = true
                    }) {
                        HStack {
                            Text("settings_profile_name")
                            Spacer()
                            Text(profile?.firstName ?? "-")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                }

                Section(String(localized: "settings_timeoff")) {
                    NavigationLink(destination: VacationManagementView()) {
                        HStack {
                            Text("My time off")
                            Spacer()
                            Text("\(vacations.filter { $0.isUpcoming }.count) planned")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(String(localized: "settings_about")) {
                    HStack {
                        Text("settings_version")
                        Spacer()
                        Text("\(AppConstants.version) (\(AppConstants.build))")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "mailto:\(AppConstants.supportEmail)")!) {
                        HStack {
                            Text("settings_support")
                            Spacer()
                            Text(AppConstants.supportEmail)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle(String(localized: "settings_title"))
            .alert(String(localized: "settings_profile_name"), isPresented: $showingNameEdit) {
                TextField(String(localized: "name_input_placeholder"), text: $editedName)
                Button(String(localized: "button_cancel"), role: .cancel) {}
                Button(String(localized: "button_save")) {
                    let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count >= 2 {
                        profile?.firstName = trimmed
                        try? modelContext.save()
                    }
                }
            }
        }
    }
}
