import SwiftUI
import SwiftData

@Observable
final class MoodViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveCheckIn(energy: Int, stress: Int, motivation: Int) -> Shift {
        let shift = getOrCreateTodayShift()
        let mood = Mood(energy: energy, stress: stress, motivation: motivation, isPreShift: true)
        modelContext.insert(mood)
        shift.preMood = mood
        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
        return shift
    }

    func saveCheckOut(fatigue: Int, emotionalLoad: Int, satisfaction: Int, badges: [String]) -> Shift {
        let shift = getOrCreateTodayShift()
        let mood = Mood(fatigue: fatigue, emotionalLoad: emotionalLoad, satisfaction: satisfaction, badges: badges)
        modelContext.insert(mood)
        shift.postMood = mood
        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
        return shift
    }

    private func getOrCreateTodayShift() -> Shift {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<Shift>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let hour = calendar.component(.hour, from: Date())
        let shiftType: ShiftType = hour >= 20 || hour < 6 ? .nuit : .jour
        let shift = Shift(date: Date(), type: shiftType)
        modelContext.insert(shift)
        try? modelContext.save()
        return shift
    }
}
