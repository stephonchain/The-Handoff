import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onComplete: () -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var firstName = ""
    @State private var vacationStart = Date()
    @State private var vacationEnd = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeView(onContinue: { currentStep = 1 })
                .tag(0)

            NameInputView(
                firstName: $firstName,
                onContinue: {
                    saveProfile()
                    currentStep = 2
                },
                onBack: { currentStep = 0 }
            )
            .tag(1)

            VacationSetupView(
                startDate: $vacationStart,
                endDate: $vacationEnd,
                onAdd: {
                    saveVacation()
                    completeOnboarding()
                },
                onSkip: { completeOnboarding() },
                onBack: { currentStep = 1 }
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentStep)
    }

    private func saveProfile() {
        let profile = UserProfile(firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines))
        profile.onboardingCompleted = true
        modelContext.insert(profile)
        try? modelContext.save()
    }

    private func saveVacation() {
        let vacation = Vacation(startDate: vacationStart, endDate: vacationEnd)
        modelContext.insert(vacation)
        try? modelContext.save()
    }

    private func completeOnboarding() {
        onComplete()
    }
}
