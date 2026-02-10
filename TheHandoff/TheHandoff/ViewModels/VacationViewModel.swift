import SwiftUI
import SwiftData

@Observable
final class VacationViewModel {
    var vacations: [Vacation] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var upcomingVacations: [Vacation] {
        vacations.filter { $0.isUpcoming || $0.isCurrent }
            .sorted { $0.startDate < $1.startDate }
    }

    var pastVacations: [Vacation] {
        vacations.filter { $0.isPast }
            .sorted { $0.endDate > $1.endDate }
    }

    @MainActor
    func loadVacations() async {
        let descriptor = FetchDescriptor<Vacation>(
            sortBy: [SortDescriptor(\.startDate)]
        )
        vacations = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addVacation(startDate: Date, endDate: Date, type: VacationType, customName: String?) {
        let vacation = Vacation(startDate: startDate, endDate: endDate, type: type)
        if let name = customName, !name.isEmpty {
            vacation.customName = name
        }
        modelContext.insert(vacation)
        try? modelContext.save()
        Task { await loadVacations() }
        HapticManager.shared.notification(type: .success)
    }

    func deleteVacation(_ vacation: Vacation) {
        modelContext.delete(vacation)
        try? modelContext.save()
        Task { await loadVacations() }
    }

    func updateVacation(_ vacation: Vacation, startDate: Date, endDate: Date, type: VacationType, customName: String?) {
        vacation.startDate = startDate
        vacation.endDate = endDate
        vacation.type = type
        vacation.customName = (customName?.isEmpty ?? true) ? nil : customName
        try? modelContext.save()
        Task { await loadVacations() }
    }
}
