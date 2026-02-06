import SwiftUI
import SwiftData

struct PostShiftCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Mood sliders (1-5)
    @State private var mood: Int = 3
    @State private var energy: Int = 3
    @State private var mentalLoad: Int = 3
    @State private var physicalPain: Int = 1

    // Free word
    @State private var freeWord: String = ""

    // Post-shift specific
    @State private var shiftFeeling: ShiftFeeling = .controlled
    @State private var didSelfCare: Bool? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🌙")
                            .font(.system(size: 48))
                        Text("Après ton shift")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Comment s'est passée ta journée ?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    // Sliders
                    VStack(spacing: 16) {
                        MoodSliderFR(
                            title: "Humeur",
                            icon: "face.smiling",
                            value: $mood,
                            labels: ["Très bas", "Bas", "Neutre", "Bien", "Très bien"],
                            color: Color(hex: "F59E0B")
                        )

                        MoodSliderFR(
                            title: "Énergie restante",
                            icon: "battery.50",
                            value: $energy,
                            labels: ["Vidé(e)", "Faible", "Moyen", "Correct", "Encore en forme"],
                            color: Color(hex: "10B981")
                        )

                        MoodSliderFR(
                            title: "Charge émotionnelle",
                            icon: "heart.fill",
                            value: $mentalLoad,
                            labels: ["Légère", "Faible", "Moyenne", "Lourde", "Écrasante"],
                            color: Color(hex: "8B5CF6")
                        )

                        MoodSliderFR(
                            title: "Fatigue physique",
                            icon: "figure.walk",
                            value: $physicalPain,
                            labels: ["Aucune", "Légère", "Modérée", "Forte", "Épuisé(e)"],
                            color: Color(hex: "EF4444")
                        )
                    }

                    // Shift feeling selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Aujourd'hui a été...")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack(spacing: 12) {
                            ForEach(ShiftFeeling.allCases, id: \.self) { feeling in
                                Button(action: {
                                    shiftFeeling = feeling
                                    HapticManager.shared.impact(style: .light)
                                }) {
                                    VStack(spacing: 6) {
                                        Text(feeling.emoji)
                                            .font(.title)
                                        Text(feeling.label)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(shiftFeeling == feeling ? feeling.color.opacity(0.15) : Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(shiftFeeling == feeling ? feeling.color : .clear, lineWidth: 2)
                                    )
                                }
                                .foregroundStyle(shiftFeeling == feeling ? feeling.color : .secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Self-care question
                    VStack(alignment: .leading, spacing: 12) {
                        Text("J'ai fait quelque chose pour moi aujourd'hui")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack(spacing: 16) {
                            Button(action: {
                                didSelfCare = true
                                HapticManager.shared.impact(style: .light)
                            }) {
                                HStack {
                                    Image(systemName: didSelfCare == true ? "checkmark.circle.fill" : "circle")
                                    Text("Oui")
                                }
                                .font(.body)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(didSelfCare == true ? Color(hex: "10B981").opacity(0.15) : Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(didSelfCare == true ? Color(hex: "10B981") : .clear, lineWidth: 2)
                                )
                            }
                            .foregroundStyle(didSelfCare == true ? Color(hex: "10B981") : .secondary)

                            Button(action: {
                                didSelfCare = false
                                HapticManager.shared.impact(style: .light)
                            }) {
                                HStack {
                                    Image(systemName: didSelfCare == false ? "xmark.circle.fill" : "circle")
                                    Text("Non")
                                }
                                .font(.body)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(didSelfCare == false ? Color(hex: "EF4444").opacity(0.15) : Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(didSelfCare == false ? Color(hex: "EF4444") : .clear, lineWidth: 2)
                                )
                            }
                            .foregroundStyle(didSelfCare == false ? Color(hex: "EF4444") : .secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Free word
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundStyle(Color(hex: "3B82F6"))
                            Text("Un mot pour résumer ta journée")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        TextField("Ex: intense, gratifiant, épuisant...", text: $freeWord)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Valider") {
                        saveCheckOut()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Color(hex: "F59E0B"))
                }
            }
        }
    }

    private func saveCheckOut() {
        let descriptor = FetchDescriptor<Shift>()
        let shifts = (try? modelContext.fetch(descriptor)) ?? []
        guard let todayShift = shifts.first(where: { Calendar.current.isDateInToday($0.date) }) else { return }

        // Create post-shift mood
        let postMood = Mood(fatigue: physicalPain, emotionalLoad: mentalLoad, satisfaction: mood, badges: [])
        postMood.energy = energy
        postMood.notes = freeWord.isEmpty ? nil : freeWord
        // Store shift feeling and self-care in badges
        var badgeData: [String] = ["feeling:\(shiftFeeling.rawValue)"]
        if let selfCare = didSelfCare {
            badgeData.append("selfcare:\(selfCare)")
        }
        postMood.badges = badgeData

        todayShift.postMood = postMood
        todayShift.endTime = Date()

        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
    }
}

// MARK: - Shift Feeling

enum ShiftFeeling: String, CaseIterable {
    case controlled = "controlled"
    case heavy = "heavy"
    case chaotic = "chaotic"

    var label: String {
        switch self {
        case .controlled: return "Maîtrisé"
        case .heavy: return "Lourd"
        case .chaotic: return "Chaotique"
        }
    }

    var emoji: String {
        switch self {
        case .controlled: return "✅"
        case .heavy: return "😮‍💨"
        case .chaotic: return "🌪️"
        }
    }

    var color: Color {
        switch self {
        case .controlled: return Color(hex: "10B981")
        case .heavy: return Color(hex: "F59E0B")
        case .chaotic: return Color(hex: "EF4444")
        }
    }
}
