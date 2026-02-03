import SwiftUI
import SwiftData

struct CheckOutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var onJournalRequest: (() -> Void)? = nil

    @State private var fatigue = 3
    @State private var emotionalLoad = 3
    @State private var satisfaction = 3
    @State private var selectedBadges: [String] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("checkout_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    MoodSlider(
                        title: String(localized: "checkout_fatigue"),
                        icon: "bed.double.fill",
                        value: $fatigue,
                        range: 1...5,
                        labels: [
                            String(localized: "fatigue_1"),
                            String(localized: "fatigue_2"),
                            String(localized: "fatigue_3"),
                            String(localized: "fatigue_4"),
                            String(localized: "fatigue_5")
                        ],
                        color: Color(hex: "94A3B8")
                    )

                    MoodSlider(
                        title: String(localized: "checkout_emotional_load"),
                        icon: "heart.fill",
                        value: $emotionalLoad,
                        range: 1...5,
                        labels: [
                            String(localized: "emotional_load_1"),
                            String(localized: "emotional_load_2"),
                            String(localized: "emotional_load_3"),
                            String(localized: "emotional_load_4"),
                            String(localized: "emotional_load_5")
                        ],
                        color: Color(hex: "F472B6")
                    )

                    MoodSlider(
                        title: String(localized: "checkout_satisfaction"),
                        icon: "face.smiling",
                        value: $satisfaction,
                        range: 1...5,
                        labels: [
                            String(localized: "satisfaction_1"),
                            String(localized: "satisfaction_2"),
                            String(localized: "satisfaction_3"),
                            String(localized: "satisfaction_4"),
                            String(localized: "satisfaction_5")
                        ],
                        color: Color(hex: "10B981")
                    )

                    EmojiMoodSelector(selectedBadges: $selectedBadges, multiSelect: true)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(spacing: 12) {
                        PrimaryButton(title: String(localized: "checkout_button_journal")) {
                            save()
                            onJournalRequest?()
                            if onJournalRequest == nil { dismiss() }
                        }

                        SecondaryButton(title: String(localized: "checkout_button_save")) {
                            save()
                            dismiss()
                        }
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

    private func save() {
        let vm = MoodViewModel(modelContext: modelContext)
        _ = vm.saveCheckOut(fatigue: fatigue, emotionalLoad: emotionalLoad, satisfaction: satisfaction, badges: selectedBadges)
    }
}
