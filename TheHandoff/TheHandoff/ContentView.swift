import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab_home"), systemImage: "house.fill")
                }
                .tag(0)

            JournalListView()
                .tabItem {
                    Label(String(localized: "tab_journal"), systemImage: "book.fill")
                }
                .tag(1)

            StatsPlaceholderView()
                .tabItem {
                    Label(String(localized: "tab_stats"), systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(String(localized: "tab_settings"), systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color(hex: "F59E0B"))
    }
}

#Preview {
    ContentView()
}
