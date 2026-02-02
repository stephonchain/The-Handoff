import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.text.clipboard")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Nurse Journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your shift handoff companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Nurse Journal")
        }
    }
}

#Preview {
    ContentView()
}
