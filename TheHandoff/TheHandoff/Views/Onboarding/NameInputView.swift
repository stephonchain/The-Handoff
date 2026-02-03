import SwiftUI

struct NameInputView: View {
    @Binding var firstName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    @FocusState private var isFocused: Bool

    var isValid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(Color(hex: "F59E0B"))
                }
                Spacer()
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 16) {
                Text("name_input_title")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                TextField(String(localized: "name_input_placeholder"), text: $firstName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($isFocused)

                Text("name_input_caption")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: String(localized: "name_input_button")) {
                onContinue()
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onAppear { isFocused = true }
    }
}
