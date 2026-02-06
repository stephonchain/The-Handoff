import SwiftUI
import SwiftData

struct ProfilView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var vacations: [Vacation]

    @State private var firstName: String = ""
    @State private var workRhythm: WorkRhythm = .standard
    @State private var serviceType: ServiceType = .hospital
    @State private var selectedGoals: Set<PersonalGoal> = []
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var remindersEnabled: Bool = false

    @State private var showingVacations = false
    @State private var showingPaywall = false
    @State private var subscriptionManager = SubscriptionManager.shared

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                // Identity section
                Section {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)

                            Text(firstName.prefix(1).uppercased())
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Ton prénom", text: $firstName)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .onChange(of: firstName) { _, newValue in
                                    updateProfile()
                                }

                            Text("Soignant(e)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }

                // Premium section
                premiumSection

                // Work section
                Section("Mon travail") {
                    Picker("Rythme de travail", selection: $workRhythm) {
                        ForEach(WorkRhythm.allCases, id: \.self) { rhythm in
                            Text(rhythm.label).tag(rhythm)
                        }
                    }
                    .onChange(of: workRhythm) { _, _ in updateProfile() }

                    Picker("Type de service", selection: $serviceType) {
                        ForEach(ServiceType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .onChange(of: serviceType) { _, _ in updateProfile() }

                    NavigationLink(destination: VacationManagementView()) {
                        HStack {
                            Label("Mes congés", systemImage: "calendar")
                            Spacer()
                            Text("\(vacations.filter { !$0.isPast }.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Goals section
                Section("Mes objectifs") {
                    ForEach(PersonalGoal.allCases, id: \.self) { goal in
                        Button(action: { toggleGoal(goal) }) {
                            HStack {
                                Image(systemName: selectedGoals.contains(goal) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedGoals.contains(goal) ? Color(hex: "F59E0B") : .secondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(goal.label)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(goal.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                // Reminders section
                Section("Rappels") {
                    Toggle("Rappels activés", isOn: $remindersEnabled)
                        .tint(Color(hex: "F59E0B"))

                    if remindersEnabled {
                        DatePicker("Heure du rappel", selection: $reminderTime, displayedComponents: .hourAndMinute)

                        Text("Les rappels s'adaptent à tes habitudes détectées")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Privacy section
                Section("Confidentialité") {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(Color(hex: "10B981"))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tes données restent sur ton appareil")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Ton journal est un sanctuaire. Aucune donnée n'est envoyée sur le cloud.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // About section
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "mailto:handoff@steverover.com")!) {
                        HStack {
                            Text("Contacter le support")
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Link(destination: URL(string: "https://handoff.steverover.com/privacy.html")!) {
                        HStack {
                            Text("Politique de confidentialité")
                            Spacer()
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Link(destination: URL(string: "https://handoff.steverover.com/terms.html")!) {
                        HStack {
                            Text("Conditions d'utilisation")
                            Spacer()
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Profil")
            .onAppear {
                loadProfile()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Premium Section
    @ViewBuilder
    private var premiumSection: some View {
        Section {
            if subscriptionManager.isPremium {
                // User is Premium
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)

                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Handoff Premium")
                            .font(.headline)

                        Text(premiumStatusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "10B981"))
                }
                .padding(.vertical, 8)
            } else {
                // User is not Premium - Show upsell
                Button {
                    showingPaywall = true
                    HapticManager.shared.impact(.light)
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)

                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Passer à Premium")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("1 semaine d'essai gratuit")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "10B981"))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private var premiumStatusText: String {
        switch subscriptionManager.subscriptionStatus {
        case .lifetime:
            return "Accès à vie actif"
        case .subscribed(let expirationDate):
            if let date = expirationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.locale = Locale(identifier: "fr_FR")
                return "Renouvellement le \(formatter.string(from: date))"
            }
            return "Abonnement actif"
        case .inTrial(let expirationDate):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "fr_FR")
            return "Essai jusqu'au \(formatter.string(from: expirationDate))"
        case .notSubscribed:
            return ""
        }
    }

    private func loadProfile() {
        if let profile = profile {
            firstName = profile.firstName
        }
    }

    private func updateProfile() {
        if let profile = profile {
            profile.firstName = firstName
        } else if !firstName.isEmpty {
            let newProfile = UserProfile(firstName: firstName)
            modelContext.insert(newProfile)
        }
        try? modelContext.save()
    }

    private func toggleGoal(_ goal: PersonalGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
        HapticManager.shared.impact(style: .light)
    }
}

// MARK: - Supporting Types

enum WorkRhythm: String, CaseIterable {
    case standard = "standard"
    case twelveHour = "12h"
    case night = "night"
    case mixed = "mixed"

    var label: String {
        switch self {
        case .standard: return "Journées standards (8h)"
        case .twelveHour: return "Postes de 12h"
        case .night: return "Nuits uniquement"
        case .mixed: return "Alternance jour/nuit"
        }
    }
}

enum ServiceType: String, CaseIterable {
    case hospital = "hospital"
    case clinic = "clinic"
    case home = "home"
    case ehpad = "ehpad"
    case liberal = "liberal"
    case other = "other"

    var label: String {
        switch self {
        case .hospital: return "Hôpital"
        case .clinic: return "Clinique"
        case .home: return "HAD / Domicile"
        case .ehpad: return "EHPAD"
        case .liberal: return "Libéral"
        case .other: return "Autre"
        }
    }
}

enum PersonalGoal: String, CaseIterable {
    case sleep = "sleep"
    case rumination = "rumination"
    case boundaries = "boundaries"
    case selfCare = "selfcare"
    case stress = "stress"
    case energy = "energy"

    var label: String {
        switch self {
        case .sleep: return "Mieux dormir"
        case .rumination: return "Moins ruminer"
        case .boundaries: return "Poser mes limites"
        case .selfCare: return "Prendre soin de moi"
        case .stress: return "Gérer mon stress"
        case .energy: return "Retrouver de l'énergie"
        }
    }

    var description: String {
        switch self {
        case .sleep: return "Améliorer la qualité de mon sommeil"
        case .rumination: return "Arrêter de repenser au travail chez moi"
        case .boundaries: return "Apprendre à dire non"
        case .selfCare: return "M'accorder du temps pour moi"
        case .stress: return "Développer des techniques de gestion du stress"
        case .energy: return "Combattre la fatigue chronique"
        }
    }
}
