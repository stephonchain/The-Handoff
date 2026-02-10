import SwiftUI
import SwiftData

@main
struct TheHandoffApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Shift.self,
            Mood.self,
            JournalEntry.self,
            Vacation.self,
            DailyAffirmation.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if onboardingCompleted {
                ContentView()
                    .modelContainer(sharedModelContainer)
            } else {
                OnboardingView(onComplete: {
                    onboardingCompleted = true
                })
                .modelContainer(sharedModelContainer)
            }
        }
    }
}
