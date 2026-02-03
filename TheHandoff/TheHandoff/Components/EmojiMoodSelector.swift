import SwiftUI

struct EmojiMoodSelector: View {
    @Binding var selectedBadges: [String]
    let badges = MoodBadge.allCases
    let multiSelect: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("checkout_badges_title")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(badges, id: \.self) { badge in
                    let isSelected = selectedBadges.contains(badge.rawValue)

                    VStack(spacing: 4) {
                        Text(badge.rawValue)
                            .font(.system(size: 32))
                        Text(LocalizedStringKey(badge.labelKey))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color(hex: "F59E0B").opacity(0.1) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        toggleBadge(badge.rawValue)
                    }
                }
            }
        }
    }

    private func toggleBadge(_ badge: String) {
        if multiSelect {
            if let index = selectedBadges.firstIndex(of: badge) {
                selectedBadges.remove(at: index)
            } else {
                selectedBadges.append(badge)
            }
        } else {
            selectedBadges = [badge]
        }
        HapticManager.shared.impact(style: .light)
    }
}
