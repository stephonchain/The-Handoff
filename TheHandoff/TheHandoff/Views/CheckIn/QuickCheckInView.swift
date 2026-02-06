import SwiftUI
import SwiftData

/// Mode "Je suis rincé(e)" - Check-in en 3 taps max
struct QuickCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var mood: Int = 3
    @State private var isPostShift: Bool = false

    private var todayHasCheckIn: Bool {
        let descriptor = FetchDescriptor<Shift>()
        let shifts = (try? modelContext.fetch(descriptor)) ?? []
        return shifts.first { Calendar.current.isDateInToday($0.date) }?.hasPreMood ?? false
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("⚡")
                    .font(.system(size: 40))
                Text("Mode express")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("3 taps et c'est fait")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)

            // Pre/Post toggle if already checked in
            if todayHasCheckIn {
                Picker("Type", selection: $isPostShift) {
                    Text("Avant shift").tag(false)
                    Text("Après shift").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            // Quick mood selector
            VStack(spacing: 12) {
                Text("Comment ça va ?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: {
                            mood = level
                            HapticManager.shared.impact(style: .medium)
                        }) {
                            VStack(spacing: 4) {
                                Text(quickMoodEmoji(level))
                                    .font(.system(size: 36))
                                Text("\(level)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(mood == level ? Color(hex: "F59E0B").opacity(0.2) : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(mood == level ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
            }

            Spacer()

            // Save button
            Button(action: saveQuickCheckIn) {
                Text("Enregistrer")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "F59E0B"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    private func quickMoodEmoji(_ level: Int) -> String {
        switch level {
        case 1: return "😫"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }

    private func saveQuickCheckIn() {
        let today = Date()
        let descriptor = FetchDescriptor<Shift>()
        let shifts = (try? modelContext.fetch(descriptor)) ?? []
        let todayShift = shifts.first { Calendar.current.isDateInToday($0.date) }

        let shift: Shift
        if let existing = todayShift {
            shift = existing
        } else {
            shift = Shift(date: today, type: .jour)
            modelContext.insert(shift)
        }

        if isPostShift || todayHasCheckIn {
            // Post-shift quick check
            let postMood = Mood(fatigue: 3, emotionalLoad: 3, satisfaction: mood, badges: ["quick:true"])
            postMood.energy = mood
            shift.postMood = postMood
            shift.endTime = today
        } else {
            // Pre-shift quick check
            let preMood = Mood(energy: mood, stress: 3, motivation: mood, isPreShift: true)
            preMood.badges = ["quick:true"]
            shift.preMood = preMood
            shift.startTime = today
        }

        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}
