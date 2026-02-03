import SwiftUI

struct MoodSlider: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let labels: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(labels[value - 1])
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                ForEach(range, id: \.self) { level in
                    Circle()
                        .fill(value >= level ? color : Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("\(level)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(value >= level ? .white : .secondary)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                value = level
                            }
                            HapticManager.shared.impact(style: .light)
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
