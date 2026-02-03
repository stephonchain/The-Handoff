import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "list.clipboard.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("The Handoff")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your shift handoff companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("The Handoff")
        }
    }
}

#Preview {
    ContentView()
}
