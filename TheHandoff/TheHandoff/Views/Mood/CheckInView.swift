import SwiftUI
import SwiftData

struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var energy = 3
    @State private var stress = 3
    @State private var motivation = 3

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("checkin_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    MoodSlider(
                        title: String(localized: "checkin_energy"),
                        icon: "bolt.fill",
                        value: $energy,
                        range: 1...5,
                        labels: [
                            String(localized: "energy_1"),
                            String(localized: "energy_2"),
                            String(localized: "energy_3"),
                            String(localized: "energy_4"),
                            String(localized: "energy_5")
                        ],
                        color: Color(hex: "F59E0B")
                    )

                    MoodSlider(
                        title: String(localized: "checkin_stress"),
                        icon: "brain.head.profile",
                        value: $stress,
                        range: 1...5,
                        labels: [
                            String(localized: "stress_1"),
                            String(localized: "stress_2"),
                            String(localized: "stress_3"),
                            String(localized: "stress_4"),
                            String(localized: "stress_5")
                        ],
                        color: Color(hex: "EF4444")
                    )

                    MoodSlider(
                        title: String(localized: "checkin_motivation"),
                        icon: "target",
                        value: $motivation,
                        range: 1...5,
                        labels: [
                            String(localized: "motivation_1"),
                            String(localized: "motivation_2"),
                            String(localized: "motivation_3"),
                            String(localized: "motivation_4"),
                            String(localized: "motivation_5")
                        ],
                        color: Color(hex: "8B5CF6")
                    )

                    PrimaryButton(title: String(localized: "checkin_button")) {
                        let vm = MoodViewModel(modelContext: modelContext)
                        _ = vm.saveCheckIn(energy: energy, stress: stress, motivation: motivation)
                        dismiss()
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
