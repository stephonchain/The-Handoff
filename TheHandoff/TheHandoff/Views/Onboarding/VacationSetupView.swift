import SwiftUI

struct VacationSetupView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onAdd: () -> Void
    let onSkip: () -> Void
    let onBack: () -> Void

    var isValid: Bool {
        endDate > startDate && startDate > Date()
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
                Button(String(localized: "timeoff_setup_skip")) { onSkip() }
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Text("timeoff_setup_title")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("timeoff_setup_subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("timeoff_setup_start")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("timeoff_setup_end")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: String(localized: "timeoff_setup_button")) {
                onAdd()
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
