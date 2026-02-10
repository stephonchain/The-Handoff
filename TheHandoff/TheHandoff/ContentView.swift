import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @State private var showStreakOverlay = false
    @State private var currentStreak = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                CheckInTabView()
                    .tabItem {
                        Label("Check-in", systemImage: "bolt.fill")
                    }
                    .tag(0)

                JournalTabView()
                    .tabItem {
                        Label("Journal", systemImage: "book.fill")
                    }
                    .tag(1)

                ProgressionView()
                    .tabItem {
                        Label("Progression", systemImage: "chart.bar.fill")
                    }
                    .tag(2)

                ProfilView()
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .tint(Color(hex: "F59E0B"))

            // Streak overlay
            if showStreakOverlay {
                StreakOverlayView(streak: currentStreak) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showStreakOverlay = false
                    }
                    StreakManager.shared.dismissAnimation()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            checkStreak()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && oldPhase == .background {
                checkStreak()
            }
        }
    }

    private func checkStreak() {
        currentStreak = StreakManager.shared.recordAppOpen()
        if StreakManager.shared.shouldShowStreakAnimation {
            // Small delay to let the UI settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showStreakOverlay = true
                }
                HapticManager.shared.notification(type: .success)
            }
        }
    }
}

#Preview {
    ContentView()
}
