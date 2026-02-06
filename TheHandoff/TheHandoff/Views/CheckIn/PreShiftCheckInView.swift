import SwiftUI
import SwiftData

struct PreShiftCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date

    // Mood sliders (1-5)
    @State private var mood: Int = 3
    @State private var energy: Int = 3
    @State private var mentalLoad: Int = 3
    @State private var physicalPain: Int = 1

    // Free word
    @State private var freeWord: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

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
                            title: "Énergie",
                            icon: "bolt.fill",
                            value: $energy,
                            labels: ["Épuisé(e)", "Faible", "Moyen", "Bon", "Plein d'énergie"],
                            color: Color(hex: "10B981")
                        )

                        MoodSliderFR(
                            title: "Charge mentale",
                            icon: "brain.head.profile",
                            value: $mentalLoad,
                            labels: ["Légère", "Faible", "Moyenne", "Lourde", "Écrasante"],
                            color: Color(hex: "8B5CF6")
                        )

                        MoodSliderFR(
                            title: "Douleur physique",
                            icon: "figure.walk",
                            value: $physicalPain,
                            labels: ["Aucune", "Légère", "Modérée", "Forte", "Intense"],
                            color: Color(hex: "EF4444")
                        )
                    }

                    // Free word
                    freeWordSection

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
                        saveCheckIn()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Color(hex: "F59E0B"))
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F59E0B").opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "F59E0B"))
            }

            Text("Avant ton shift")
                .font(.title2)
                .fontWeight(.bold)

            if !Calendar.current.isDateInToday(date) {
                Text(date, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "F59E0B"))
            }

            Text("Comment tu te sens ?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private var freeWordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "text.bubble")
                    .foregroundStyle(Color(hex: "3B82F6"))
                Text("Un mot pour décrire ton état")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            TextField("Ex: motivé, fatigué, stressé...", text: $freeWord)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func saveCheckIn() {
        let descriptor = FetchDescriptor<Shift>()
        let shifts = (try? modelContext.fetch(descriptor)) ?? []
        let existingShift = shifts.first { Calendar.current.isDate($0.date, inSameDayAs: date) }

        let shift: Shift
        if let existing = existingShift {
            shift = existing
        } else {
            shift = Shift(date: date, type: .jour)
            modelContext.insert(shift)
        }

        // Create pre-shift mood
        let preMood = Mood(energy: energy, stress: mentalLoad, motivation: mood, isPreShift: true)
        preMood.notes = freeWord.isEmpty ? nil : freeWord
        preMood.badges = ["pain:\(physicalPain)"]

        shift.preMood = preMood
        shift.startTime = date

        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
    }
}

// MARK: - Edit Pre-Shift View

struct EditPreShiftView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let shift: Shift
    let mood: Mood

    @State private var moodValue: Int
    @State private var energy: Int
    @State private var mentalLoad: Int
    @State private var physicalPain: Int
    @State private var freeWord: String

    init(shift: Shift, mood: Mood) {
        self.shift = shift
        self.mood = mood
        _moodValue = State(initialValue: mood.motivation)
        _energy = State(initialValue: mood.energy)
        _mentalLoad = State(initialValue: mood.stress)
        // Extract physical pain from badges
        let painBadge = mood.badges.first { $0.hasPrefix("pain:") }
        let painValue = painBadge?.replacingOccurrences(of: "pain:", with: "")
        _physicalPain = State(initialValue: Int(painValue ?? "1") ?? 1)
        _freeWord = State(initialValue: mood.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "F59E0B").opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: "pencil")
                                .font(.system(size: 28))
                                .foregroundStyle(Color(hex: "F59E0B"))
                        }

                        Text("Modifier - Avant shift")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(shift.date, format: .dateTime.day().month().year())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    // Sliders
                    VStack(spacing: 16) {
                        MoodSliderFR(
                            title: "Humeur",
                            icon: "face.smiling",
                            value: $moodValue,
                            labels: ["Très bas", "Bas", "Neutre", "Bien", "Très bien"],
                            color: Color(hex: "F59E0B")
                        )

                        MoodSliderFR(
                            title: "Énergie",
                            icon: "bolt.fill",
                            value: $energy,
                            labels: ["Épuisé(e)", "Faible", "Moyen", "Bon", "Plein d'énergie"],
                            color: Color(hex: "10B981")
                        )

                        MoodSliderFR(
                            title: "Charge mentale",
                            icon: "brain.head.profile",
                            value: $mentalLoad,
                            labels: ["Légère", "Faible", "Moyenne", "Lourde", "Écrasante"],
                            color: Color(hex: "8B5CF6")
                        )

                        MoodSliderFR(
                            title: "Douleur physique",
                            icon: "figure.walk",
                            value: $physicalPain,
                            labels: ["Aucune", "Légère", "Modérée", "Forte", "Intense"],
                            color: Color(hex: "EF4444")
                        )
                    }

                    // Free word
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundStyle(Color(hex: "3B82F6"))
                            Text("Un mot pour décrire ton état")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        TextField("Ex: motivé, fatigué, stressé...", text: $freeWord)
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
                    Button("Enregistrer") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Color(hex: "F59E0B"))
                }
            }
        }
    }

    private func saveChanges() {
        mood.motivation = moodValue
        mood.energy = energy
        mood.stress = mentalLoad
        mood.notes = freeWord.isEmpty ? nil : freeWord
        mood.badges = ["pain:\(physicalPain)"]

        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
    }
}

// MARK: - French Mood Slider

struct MoodSliderFR: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let labels: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(labels[value - 1])
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(value >= level ? color : Color.gray.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Text("\(level)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(value >= level ? .white : .secondary)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                value = level
                            }
                            HapticManager.shared.impact(style: .light)
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
