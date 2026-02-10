import SwiftUI

struct TagChipView: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    let onRemove: (() -> Void)?

    init(tag: String, isSelected: Bool, onTap: @escaping () -> Void, onRemove: (() -> Void)? = nil) {
        self.tag = tag
        self.isSelected = isSelected
        self.onTap = onTap
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isSelected ? Color(hex: "F59E0B") : Color(.systemGray5))
        )
        .foregroundStyle(isSelected ? .white : .primary)
        .onTapGesture(perform: onTap)
    }
}

struct TagSelectorView: View {
    @Binding var selectedTags: [String]
    @State private var customTag = ""

    let suggestedTags = [
        String(localized: "tag_difficult_shift"),
        String(localized: "tag_great_encounter"),
        String(localized: "tag_learning"),
        String(localized: "tag_great_team"),
        String(localized: "tag_fatigue"),
        String(localized: "tag_pride"),
        String(localized: "tag_questioning"),
        String(localized: "tag_emergency"),
        String(localized: "tag_death"),
        String(localized: "tag_recovery"),
        String(localized: "tag_family")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("journal_field_tags")
                .font(.subheadline)
                .fontWeight(.medium)

            FlowLayout(spacing: 8) {
                ForEach(suggestedTags, id: \.self) { tag in
                    TagChipView(
                        tag: tag,
                        isSelected: selectedTags.contains(tag),
                        onTap: { toggleTag(tag) }
                    )
                }

                ForEach(selectedTags.filter { !suggestedTags.contains($0) }, id: \.self) { tag in
                    TagChipView(
                        tag: tag,
                        isSelected: true,
                        onTap: {},
                        onRemove: { removeTag(tag) }
                    )
                }
            }

            HStack {
                TextField("Add custom tag", text: $customTag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addCustomTag() }

                Button("button_add") { addCustomTag() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "F59E0B"))
                    .disabled(customTag.isEmpty)
            }
        }
    }

    private func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else if selectedTags.count < AppConstants.Limits.maxTags {
            selectedTags.append(tag)
        }
    }

    private func removeTag(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
    }

    private func addCustomTag() {
        let trimmed = customTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !selectedTags.contains(trimmed) && selectedTags.count < AppConstants.Limits.maxTags {
            selectedTags.append(trimmed)
            customTag = ""
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX - spacing)
            }

            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}
