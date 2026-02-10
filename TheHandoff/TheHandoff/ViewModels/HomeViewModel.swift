import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var userProfile: UserProfile?
    var todayAffirmation: DailyAffirmation?
    var nextVacation: Vacation?
    var daysUntilVacation: Int = 0

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @MainActor
    func loadData() async {
        await fetchUserProfile()
        await fetchTodayAffirmation()
        await fetchNextVacation()
        calculateVacationCountdown()
    }

    @MainActor
    private func fetchUserProfile() async {
        let descriptor = FetchDescriptor<UserProfile>()
        userProfile = try? modelContext.fetch(descriptor).first
    }

    @MainActor
    private func fetchTodayAffirmation() async {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyAffirmation>(
            predicate: #Predicate { $0.shownDate == today }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            todayAffirmation = existing
        } else {
            todayAffirmation = generateTodayAffirmation()
        }
    }

    @MainActor
    private func fetchNextVacation() async {
        let now = Date()
        let descriptor = FetchDescriptor<Vacation>(
            predicate: #Predicate { $0.startDate > now },
            sortBy: [SortDescriptor(\.startDate)]
        )
        nextVacation = try? modelContext.fetch(descriptor).first
    }

    private func calculateVacationCountdown() {
        guard let vacation = nextVacation else {
            daysUntilVacation = 0
            return
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let vacationStart = calendar.startOfDay(for: vacation.startDate)

        if let days = calendar.dateComponents([.day], from: today, to: vacationStart).day {
            daysUntilVacation = max(0, days)
        }
    }

    private func generateTodayAffirmation() -> DailyAffirmation {
        let data = AffirmationsLibrary.getAffirmationForDay()
        let affirmation = DailyAffirmation(text: data.text, category: data.category)
        affirmation.shownDate = Calendar.current.startOfDay(for: Date())
        modelContext.insert(affirmation)
        try? modelContext.save()
        return affirmation
    }

    func toggleAffirmationLike() {
        guard let affirmation = todayAffirmation else { return }
        affirmation.liked.toggle()
        try? modelContext.save()
        HapticManager.shared.impact(style: .light)
    }

    func todayShift() -> Shift? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<Shift>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        return try? modelContext.fetch(descriptor).first
    }
}
