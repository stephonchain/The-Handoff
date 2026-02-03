import SwiftUI

struct StatsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("stats_coming_soon_title")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("stats_coming_soon_subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .navigationTitle(String(localized: "stats_title"))
        }
    }
}
