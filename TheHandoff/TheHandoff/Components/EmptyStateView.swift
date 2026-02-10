import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let buttonTitle, let buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "F59E0B"))
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
    }
}
