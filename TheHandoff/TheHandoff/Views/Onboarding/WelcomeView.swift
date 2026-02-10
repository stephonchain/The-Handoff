import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.text.clipboard.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "F59E0B"))

            VStack(spacing: 8) {
                Text(AppConstants.appName)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("welcome_subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "face.smiling", text: String(localized: "welcome_feature_1"))
                FeatureRow(icon: "book.fill", text: String(localized: "welcome_feature_2"))
                FeatureRow(icon: "calendar.badge.clock", text: String(localized: "welcome_feature_3"))
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: String(localized: "welcome_button")) {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(hex: "F59E0B"))
                .frame(width: 32)
            Text(text)
                .font(.body)
        }
    }
}
