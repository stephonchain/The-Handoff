import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "F59E0B").opacity(0.3), radius: 8, y: 4)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "F59E0B"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "F59E0B").opacity(0.1))
                .clipShape(Capsule())
        }
    }
}
