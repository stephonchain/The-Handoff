import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
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
    }
}

#Preview {
    ContentView()
}
