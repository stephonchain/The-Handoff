import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onComplete: () -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0

    // User data
    @State private var firstName = ""
    @State private var serviceType: ServiceType = .hospital
    @State private var workRhythm: WorkRhythm = .standard
    @State private var vacationStart = Date()
    @State private var vacationEnd = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    // Burnout assessment (1-5 scale)
    @State private var exhaustionScore: Int = 3
    @State private var disconnectScore: Int = 3
    @State private var prideScore: Int = 3

    // Paywall
    @State private var showPaywall = false

    private let totalSteps = 9

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                if currentStep > 0 && currentStep < 8 {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps - 1))
                        .tint(Color(hex: "F59E0B"))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                TabView(selection: $currentStep) {
                    // 0: Welcome
                    OnboardingWelcomeStep(onContinue: { nextStep() })
                        .tag(0)

                    // 1: Name
                    OnboardingNameStep(
                        firstName: $firstName,
                        onContinue: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(1)

                    // 2: Service Type → Check-in feature
                    OnboardingServiceStep(
                        serviceType: $serviceType,
                        onContinue: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(2)

                    // 3: Work Rhythm → Reminders feature
                    OnboardingRhythmStep(
                        workRhythm: $workRhythm,
                        onContinue: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(3)

                    // 4: Burnout Q1 - Exhaustion → Journal feature
                    OnboardingBurnoutStep(
                        score: $exhaustionScore,
                        question: "Je me sens épuisé(e) émotionnellement après mes shifts",
                        featureIcon: "book.fill",
                        featureTitle: "Ton Journal personnel",
                        featureDescription: "Décharge tes émotions en toute confidentialité. Écris, ajoute des photos ou enregistre des notes vocales.",
                        onContinue: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(4)

                    // 5: Burnout Q2 - Disconnect → Stats feature
                    OnboardingBurnoutStep(
                        score: $disconnectScore,
                        question: "J'ai du mal à décrocher mentalement du travail",
                        featureIcon: "chart.line.uptrend.xyaxis",
                        featureTitle: "Suivi de ta progression",
                        featureDescription: "Visualise l'évolution de ton bien-être et identifie ce qui t'aide à déconnecter.",
                        onContinue: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(5)

                    // 6: Burnout Q3 - Pride → Badges feature
                    OnboardingBurnoutStep(
                        score: $prideScore,
                        question: "Je ressens encore de la fierté dans mon travail",
                        featureIcon: "trophy.fill",
                        featureTitle: "Célèbre tes victoires",
                        featureDescription: "Gagne des badges et suis ta série. Chaque check-in compte, chaque petit pas est une victoire.",
                        isPositiveScale: true,
                        onContinue: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(6)

                    // 7: Vacation → Countdown feature
                    OnboardingVacationStep(
                        startDate: $vacationStart,
                        endDate: $vacationEnd,
                        onContinue: {
                            saveVacation()
                            nextStep()
                        },
                        onSkip: { nextStep() },
                        onBack: { previousStep() }
                    )
                    .tag(7)

                    // 8: Summary
                    OnboardingSummaryStep(
                        firstName: firstName,
                        exhaustionScore: exhaustionScore,
                        disconnectScore: disconnectScore,
                        prideScore: prideScore,
                        onContinue: {
                            saveProfile()
                            showPaywall = true
                        },
                        onBack: { previousStep() }
                    )
                    .tag(8)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .scrollDisabled(true) // Disable swipe to prevent conflict with DatePicker
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            completeOnboarding()
        }) {
            PaywallView()
        }
    }

    private func nextStep() {
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation {
            currentStep += 1
        }
        HapticManager.shared.impact(style: .light)
    }

    private func previousStep() {
        withAnimation {
            currentStep -= 1
        }
    }

    private func saveProfile() {
        let cleanedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = UserProfile(firstName: cleanedName)
        profile.onboardingCompleted = true
        profile.serviceType = serviceType.rawValue
        profile.workRhythm = workRhythm.rawValue
        modelContext.insert(profile)
        try? modelContext.save()
    }

    private func saveVacation() {
        let vacation = Vacation(startDate: vacationStart, endDate: vacationEnd)
        modelContext.insert(vacation)
        try? modelContext.save()
    }

    private func completeOnboarding() {
        onComplete()
    }
}

// MARK: - Welcome Step
struct OnboardingWelcomeStep: View {
    let onContinue: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "F59E0B").opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animate ? 1.1 : 1.0)

                Image(systemName: "heart.text.clipboard.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(Color(hex: "F59E0B"))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }

            VStack(spacing: 12) {
                Text("Handoff")
                    .font(.system(size: 42, weight: .bold))

                Text("Prends soin de toi,\nshift après shift")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 8) {
                Text("Rejoins les soignants qui ont choisi\nde prendre soin d'eux")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            OnboardingPrimaryButton(title: "Commencer") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Name Step
struct OnboardingNameStep: View {
    @Binding var firstName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    @FocusState private var isFocused: Bool

    var isValid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(onBack: onBack)

            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "F59E0B"))

                Text("Comment tu t'appelles ?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                TextField("Ton prénom", text: $firstName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($isFocused)

                Text("On va personnaliser ton expérience")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)

            Spacer()

            OnboardingPrimaryButton(title: "Continuer") {
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

// MARK: - Service Type Step
struct OnboardingServiceStep: View {
    @Binding var serviceType: ServiceType
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(onBack: onBack)

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "F59E0B"))

                    Text("Où travailles-tu ?")
                        .font(.title)
                        .fontWeight(.bold)

                    VStack(spacing: 12) {
                        ForEach(ServiceType.allCases, id: \.self) { type in
                            OnboardingSelectionButton(
                                title: type.label,
                                icon: type.icon,
                                isSelected: serviceType == type
                            ) {
                                serviceType = type
                                HapticManager.shared.impact(style: .light)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    FeaturePreviewCard(
                        icon: "checkmark.circle.fill",
                        title: "Check-in adapté",
                        description: "Tes check-ins seront adaptés à ton environnement de travail"
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.top, 16)
            }

            OnboardingPrimaryButton(title: "Continuer") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Work Rhythm Step
struct OnboardingRhythmStep: View {
    @Binding var workRhythm: WorkRhythm
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(onBack: onBack)

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "F59E0B"))

                    Text("Quel est ton rythme ?")
                        .font(.title)
                        .fontWeight(.bold)

                    VStack(spacing: 12) {
                        ForEach(WorkRhythm.allCases, id: \.self) { rhythm in
                            OnboardingSelectionButton(
                                title: rhythm.label,
                                icon: rhythm.icon,
                                isSelected: workRhythm == rhythm
                            ) {
                                workRhythm = rhythm
                                HapticManager.shared.impact(style: .light)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    FeaturePreviewCard(
                        icon: "bell.badge.fill",
                        title: "Rappels intelligents",
                        description: "On te rappellera de faire ton check-in au bon moment"
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.top, 16)
            }

            OnboardingPrimaryButton(title: "Continuer") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Burnout Assessment Step
struct OnboardingBurnoutStep: View {
    @Binding var score: Int
    let question: String
    let featureIcon: String
    let featureTitle: String
    let featureDescription: String
    var isPositiveScale: Bool = false
    let onContinue: () -> Void
    let onBack: () -> Void

    private let scaleLabels = ["Jamais", "Rarement", "Parfois", "Souvent", "Toujours"]

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(onBack: onBack)

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text(question)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { value in
                                    OnboardingScoreButton(
                                        value: value,
                                        isSelected: score == value,
                                        color: scoreColor(value)
                                    ) {
                                        score = value
                                        HapticManager.shared.impact(style: .light)
                                    }
                                }
                            }

                            Text(scaleLabels[score - 1])
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                    }

                    FeaturePreviewCard(
                        icon: featureIcon,
                        title: featureTitle,
                        description: featureDescription
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.top, 32)
            }

            OnboardingPrimaryButton(title: "Continuer") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func scoreColor(_ value: Int) -> Color {
        if isPositiveScale {
            switch value {
            case 1: return Color(hex: "EF4444")
            case 2: return Color(hex: "F97316")
            case 3: return Color(hex: "F59E0B")
            case 4: return Color(hex: "84CC16")
            case 5: return Color(hex: "10B981")
            default: return Color(hex: "F59E0B")
            }
        } else {
            switch value {
            case 1: return Color(hex: "10B981")
            case 2: return Color(hex: "84CC16")
            case 3: return Color(hex: "F59E0B")
            case 4: return Color(hex: "F97316")
            case 5: return Color(hex: "EF4444")
            default: return Color(hex: "F59E0B")
            }
        }
    }
}

// MARK: - Vacation Step
struct OnboardingVacationStep: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onContinue: () -> Void
    let onSkip: () -> Void
    let onBack: () -> Void

    var isValid: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        return endDate >= startDate && start >= today
    }

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(onBack: onBack)

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(hex: "F59E0B"))

                    VStack(spacing: 8) {
                        Text("Des congés en vue ?")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Rien de tel qu'un compte à rebours pour tenir le coup")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 16) {
                        DatePicker("Début", selection: $startDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        DatePicker("Fin", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)

                    FeaturePreviewCard(
                        icon: "calendar.badge.clock",
                        title: "Compte à rebours",
                        description: "Visualise le temps qu'il te reste avant tes prochains congés"
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.top, 16)
            }

            VStack(spacing: 12) {
                OnboardingPrimaryButton(title: "Ajouter mes congés") {
                    onContinue()
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.5)

                Button("Passer cette étape") {
                    onSkip()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Summary Step
struct OnboardingSummaryStep: View {
    let firstName: String
    let exhaustionScore: Int
    let disconnectScore: Int
    let prideScore: Int
    let onContinue: () -> Void
    let onBack: () -> Void

    private var wellbeingLevel: WellbeingLevel {
        let invertedExhaustion = 6 - exhaustionScore
        let invertedDisconnect = 6 - disconnectScore
        let totalScore = invertedExhaustion + invertedDisconnect + prideScore

        if totalScore >= 12 {
            return .good
        } else if totalScore >= 8 {
            return .moderate
        } else {
            return .needsAttention
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(onBack: onBack)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text(verbatim: "Merci \(firstName.trimmingCharacters(in: .whitespacesAndNewlines)) !")
                            .font(.title)
                            .fontWeight(.bold)

                        Text(wellbeingLevel.message)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 16) {
                        WellbeingIndicator(level: wellbeingLevel)

                        Text(wellbeingLevel.title)
                            .font(.headline)
                            .foregroundStyle(wellbeingLevel.color)
                    }
                    .padding(.vertical, 24)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Handoff va t'aider à :")
                            .font(.headline)

                        ForEach(wellbeingLevel.recommendations, id: \.self) { recommendation in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: "10B981"))
                                Text(recommendation)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)
                }
                .padding(.top, 16)
            }

            OnboardingPrimaryButton(title: "Découvrir Handoff") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Supporting Types
enum WellbeingLevel {
    case good, moderate, needsAttention

    var title: String {
        switch self {
        case .good: return "Plutôt en forme !"
        case .moderate: return "Vigilance recommandée"
        case .needsAttention: return "Prends soin de toi"
        }
    }

    var message: String {
        switch self {
        case .good:
            return "Tu sembles bien gérer la pression. Handoff va t'aider à maintenir cet équilibre."
        case .moderate:
            return "Quelques signaux méritent ton attention. Handoff va t'aider à mieux te connaître."
        case .needsAttention:
            return "Tu traverses peut-être une période difficile. Handoff est là pour t'accompagner."
        }
    }

    var color: Color {
        switch self {
        case .good: return Color(hex: "10B981")
        case .moderate: return Color(hex: "F59E0B")
        case .needsAttention: return Color(hex: "EF4444")
        }
    }

    var recommendations: [String] {
        switch self {
        case .good:
            return [
                "Maintenir ta routine de bien-être",
                "Célébrer tes petites victoires",
                "Garder un œil sur ton évolution"
            ]
        case .moderate:
            return [
                "Identifier ce qui te pèse",
                "Trouver des moments pour décompresser",
                "Suivre ton évolution au fil du temps"
            ]
        case .needsAttention:
            return [
                "Exprimer ce que tu ressens",
                "Détecter les sources de stress",
                "Construire une routine de récupération"
            ]
        }
    }
}

// MARK: - Reusable Components
struct OnboardingHeader: View {
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(hex: "F59E0B"))
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}

struct OnboardingSelectionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color(hex: "F59E0B") : .secondary)
                    .frame(width: 32)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "F59E0B"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingScoreButton: View {
    let value: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(value)")
                .font(.headline)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? color : Color(.systemGray5))
                )
        }
    }
}

struct FeaturePreviewCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F59E0B").opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: "F59E0B"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "F59E0B").opacity(0.05))
        )
    }
}

struct WellbeingIndicator: View {
    let level: WellbeingLevel

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 8)
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: trimAmount)
                .stroke(level.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))

            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundStyle(level.color)
        }
    }

    private var trimAmount: CGFloat {
        switch level {
        case .good: return 0.85
        case .moderate: return 0.55
        case .needsAttention: return 0.3
        }
    }

    private var iconName: String {
        switch level {
        case .good: return "face.smiling.fill"
        case .moderate: return "face.smiling"
        case .needsAttention: return "heart.fill"
        }
    }
}

struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Extensions
extension ServiceType {
    var icon: String {
        switch self {
        case .hospital: return "building.2.fill"
        case .clinic: return "cross.case.fill"
        case .home: return "house.fill"
        case .ehpad: return "person.2.fill"
        case .liberal: return "briefcase.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

extension WorkRhythm {
    var icon: String {
        switch self {
        case .standard: return "sun.max.fill"
        case .twelveHour: return "clock.fill"
        case .night: return "moon.fill"
        case .mixed: return "arrow.triangle.2.circlepath"
        }
    }
}
