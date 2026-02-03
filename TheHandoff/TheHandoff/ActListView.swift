import SwiftUI

struct ActListView: View {
    let category: Category
    @ObservedObject var dataStore: DataStore
    @StateObject private var userSettings = UserSettings.shared

    @State private var selectedAct: Act?

    var acts: [Act] {
        dataStore.actsForCategory(category.id)
    }

    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(acts) { act in
                        ActCard(act: act)
                            .onTapGesture {
                                userSettings.triggerHaptic(.light)
                                selectedAct = act
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedAct) { act in
            ActDetailSheet(act: act)
        }
    }
}
