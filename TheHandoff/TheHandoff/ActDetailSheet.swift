import SwiftUI

struct ActDetailSheet: View {
    let act: Act
    @StateObject private var userSettings = UserSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Code badge
                        Text(act.code)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.pastelLavandeDeep)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.pastelLavande.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Title
                        Text(act.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.textWarm)
                            .multilineTextAlignment(.center)

                        // Price
                        VStack(spacing: 4) {
                            Text("Tarif")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textMuted)

                            Text(Tarifs.calculatePrice(for: act))
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.pastelMentheDeep)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)

                        // Details
                        if act.coef > 0 {
                            VStack(spacing: 12) {
                                DetailRow(label: "Coefficient", value: String(format: "%.1f", act.coef))
                                if !act.notes.isEmpty {
                                    DetailRow(label: "Notes", value: act.notes)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                        }

                        // Favorite button
                        Button(action: {
                            userSettings.toggleFavorite(act.id.uuidString)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: userSettings.isFavorite(act.id.uuidString) ? "heart.fill" : "heart")
                                    .font(.system(size: 16))
                                Text(userSettings.isFavorite(act.id.uuidString) ? "Retirer des favoris" : "Ajouter aux favoris")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(userSettings.isFavorite(act.id.uuidString) ? .pastelRoseDeep : .pastelLavandeDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                userSettings.isFavorite(act.id.uuidString)
                                    ? Color.pastelRose.opacity(0.2)
                                    : Color.pastelLavande.opacity(0.15)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Détail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(.pastelLavandeDeep)
                }
            }
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textMuted)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textWarm)
        }
    }
}
