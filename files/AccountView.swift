import SwiftUI
import StoreKit
import MessageUI

// MARK: - Account View

struct AccountView: View {
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var trialManager = TrialManager.shared
    @StateObject private var userSettings = UserSettings.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPaywall = false
    @State private var showingExportOptions = false
    @State private var showingResetAlert = false
    @State private var showingShareSheet = false
    @State private var showingMailComposer = false
    @State private var showingMailError = false
    
    // App Store ID - À remplacer par le vrai ID après publication
    private let appStoreID = "6740000000" // Remplacer par le vrai ID
    private let contactEmail = "ngap@arcachon.care"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Subscription Card
                        subscriptionCard
                        
                        // User Info Section
                        userInfoSection
                        
                        // Preferences Section
                        preferencesSection
                        
                        // Tools Section
                        toolsSection
                        
                        // About Section
                        aboutSection
                        
                        // App Version
                        versionInfo
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Mon Compte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pastelLavandeDeep)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [
                    "Découvre NGAP IDEL, l'app indispensable pour les infirmiers libéraux ! 👩‍⚕️",
                    URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
                ])
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    recipient: contactEmail,
                    subject: "NGAP IDEL - Contact",
                    body: "\n\n---\nEnvoyé depuis NGAP IDEL v2.0"
                )
            }
            .alert("Réinitialiser les données ?", isPresented: $showingResetAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Réinitialiser", role: .destructive) {
                    userSettings.resetAll()
                }
            } message: {
                Text("Cette action supprimera vos informations personnelles et vos favoris. Cette action est irréversible.")
            }
            .alert("Impossible d'envoyer un email", isPresented: $showingMailError) {
                Button("Copier l'adresse") {
                    UIPasteboard.general.string = contactEmail
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Aucune application de messagerie n'est configurée. Vous pouvez nous contacter à : \(contactEmail)")
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pastelRose, .pastelLavande],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                if let initials = userSettings.initials {
                    Text(initials)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: .pastelLavande.opacity(0.4), radius: 10, x: 0, y: 5)
            
            // Name
            VStack(spacing: 4) {
                if let name = userSettings.nurseName, !name.isEmpty {
                    Text(name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textWarm)
                } else {
                    Text("Infirmier(ère) IDEL")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textWarm)
                }
                
                if storeManager.hasActiveSubscription {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                        Text("Compte Pro")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.pastelMentheDeep)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Subscription Card
    
    private var subscriptionCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Abonnement")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textMuted)
                    
                    if storeManager.hasActiveSubscription {
                        Text("NGAP Pro actif")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.pastelMentheDeep)
                    } else if trialManager.isTrialActive {
                        Text("Essai gratuit")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.pastelCielDeep)
                        
                        Text("\(trialManager.daysRemaining) jour\(trialManager.daysRemaining > 1 ? "s" : "") restant\(trialManager.daysRemaining > 1 ? "s" : "")")
                            .font(.system(size: 13))
                            .foregroundColor(.textMuted)
                    } else {
                        Text("Gratuit (limité)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textSoft)
                    }
                }
                
                Spacer()
                
                // Status icon
                ZStack {
                    Circle()
                        .fill(storeManager.hasActiveSubscription ? Color.pastelMenthe.opacity(0.2) : Color.pastelLavande.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: storeManager.hasActiveSubscription ? "crown.fill" : "lock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(storeManager.hasActiveSubscription ? .pastelMentheDeep : .pastelLavandeDeep)
                }
            }
            
            Divider()
            
            // Actions
            if storeManager.hasActiveSubscription {
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Gérer mon abonnement")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.pastelLavandeDeep)
                }
            } else {
                Button(action: { showingPaywall = true }) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Passer à Pro")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            colors: [.pastelLavandeDeep, .pastelRoseDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 5)
    }
    
    // MARK: - User Info Section
    
    private var userInfoSection: some View {
        SectionCard(title: "Mes informations", icon: "person.text.rectangle") {
            VStack(spacing: 0) {
                DirectEditableRow(
                    icon: "person.fill",
                    title: "Nom",
                    value: $userSettings.nurseName,
                    placeholder: "Votre nom"
                )
                
                Divider().padding(.leading, 44)
                
                DirectEditableRow(
                    icon: "cross.case.fill",
                    title: "Cabinet",
                    value: $userSettings.cabinetName,
                    placeholder: "Nom du cabinet"
                )
                
                Divider().padding(.leading, 44)
                
                DirectEditableRow(
                    icon: "mappin.circle.fill",
                    title: "Adresse",
                    value: $userSettings.cabinetAddress,
                    placeholder: "Adresse du cabinet"
                )
                
                Divider().padding(.leading, 44)
                
                DirectEditableRow(
                    icon: "phone.fill",
                    title: "Téléphone",
                    value: $userSettings.phone,
                    placeholder: "Numéro de téléphone",
                    keyboardType: .phonePad
                )
                
                Divider().padding(.leading, 44)
                
                DirectEditableRow(
                    icon: "number",
                    title: "N° ADELI",
                    value: $userSettings.adeliNumber,
                    placeholder: "Votre numéro ADELI",
                    keyboardType: .numberPad
                )
            }
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        SectionCard(title: "Préférences", icon: "slider.horizontal.3") {
            VStack(spacing: 0) {
                // Newsletter
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.pastelCielDeep)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Newsletter")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textWarm)
                        
                        if userSettings.newsletterEnabled, let email = userSettings.email, !email.isEmpty {
                            Text(email)
                                .font(.system(size: 12))
                                .foregroundColor(.textMuted)
                        }
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $userSettings.newsletterEnabled)
                        .tint(.pastelMentheDeep)
                        .onChange(of: userSettings.newsletterEnabled) { _, newValue in
                            if newValue {
                                // Envoyer l'email au serveur quand activé
                                sendEmailToServer()
                            }
                        }
                }
                .padding(.vertical, 12)
                
                if userSettings.newsletterEnabled {
                    Divider().padding(.leading, 44)
                    
                    DirectEditableRow(
                        icon: "at",
                        title: "Email",
                        value: $userSettings.email,
                        placeholder: "votre@email.com",
                        keyboardType: .emailAddress,
                        onSubmit: {
                            sendEmailToServer()
                        }
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Notifications
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.pastelSoleilDeep)
                        .frame(width: 28)
                    
                    Text("Notifications")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textWarm)
                    
                    Spacer()
                    
                    Toggle("", isOn: $userSettings.notificationsEnabled)
                        .tint(.pastelMentheDeep)
                }
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 44)
                
                // Haptic feedback
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.pastelLavandeDeep)
                        .frame(width: 28)
                    
                    Text("Retour haptique")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textWarm)
                    
                    Spacer()
                    
                    Toggle("", isOn: $userSettings.hapticEnabled)
                        .tint(.pastelMentheDeep)
                }
                .padding(.vertical, 12)
            }
        }
    }
    
    // MARK: - Tools Section
    
    private var toolsSection: some View {
        SectionCard(title: "Outils", icon: "wrench.and.screwdriver") {
            VStack(spacing: 0) {
                // Favoris
                NavigationLink(destination: FavoritesView()) {
                    ToolRow(
                        icon: "heart.fill",
                        iconColor: .pastelRoseDeep,
                        title: "Mes favoris",
                        subtitle: "\(userSettings.favoriteActIDs.count) acte\(userSettings.favoriteActIDs.count > 1 ? "s" : "")"
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Historique de recherche
                NavigationLink(destination: SearchHistoryView()) {
                    ToolRow(
                        icon: "clock.fill",
                        iconColor: .pastelCielDeep,
                        title: "Historique",
                        subtitle: "Recherches récentes"
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Export
                Button(action: { showingExportOptions = true }) {
                    ToolRow(
                        icon: "square.and.arrow.up.fill",
                        iconColor: .pastelMentheDeep,
                        title: "Exporter mes données",
                        subtitle: "PDF ou CSV"
                    )
                }
                .confirmationDialog("Exporter", isPresented: $showingExportOptions) {
                    Button("Exporter en PDF") {
                        exportData(format: .pdf)
                    }
                    Button("Exporter en CSV") {
                        exportData(format: .csv)
                    }
                    Button("Annuler", role: .cancel) { }
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        SectionCard(title: "À propos", icon: "info.circle") {
            VStack(spacing: 0) {
                // Noter l'app
                Button(action: requestAppStoreReview) {
                    ToolRow(
                        icon: "star.fill",
                        iconColor: .pastelSoleilDeep,
                        title: "Noter l'application",
                        subtitle: "Votre avis compte !"
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Partager
                Button(action: { showingShareSheet = true }) {
                    ToolRow(
                        icon: "square.and.arrow.up",
                        iconColor: .pastelCielDeep,
                        title: "Partager l'app",
                        subtitle: "Recommander à un collègue"
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Contact
                Button(action: openMailComposer) {
                    ToolRow(
                        icon: "envelope.fill",
                        iconColor: .pastelLavandeDeep,
                        title: "Nous contacter",
                        subtitle: contactEmail
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Mentions légales
                NavigationLink(destination: LegalView(contactEmail: contactEmail)) {
                    ToolRow(
                        icon: "doc.text.fill",
                        iconColor: .textMuted,
                        title: "Mentions légales",
                        subtitle: "CGU, confidentialité"
                    )
                }
                
                Divider().padding(.leading, 44)
                
                // Reset
                Button(action: { showingResetAlert = true }) {
                    ToolRow(
                        icon: "trash.fill",
                        iconColor: .pastelPecheDeep,
                        title: "Réinitialiser",
                        subtitle: "Effacer mes données"
                    )
                }
            }
        }
    }
    
    // MARK: - Version Info
    
    private var versionInfo: some View {
        VStack(spacing: 4) {
            Text("NGAP IDEL")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textMuted)
            
            Text("Version 2.0 - Janvier 2026")
                .font(.system(size: 12))
                .foregroundColor(.textMuted.opacity(0.7))
            
            Text("Données NGAP au 01/07/2025")
                .font(.system(size: 11))
                .foregroundColor(.textMuted.opacity(0.5))
        }
        .padding(.top, 10)
    }
    
    // MARK: - Actions
    
    private func requestAppStoreReview() {
        // Méthode 1: SKStoreReviewController (popup native)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        // Alternative: Ouvrir directement la page de l'app sur l'App Store
        // Décommenter si le popup ne fonctionne pas (ex: déjà affiché récemment)
        // if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
        //     UIApplication.shared.open(url)
        // }
    }
    
    private func openMailComposer() {
        // Vérifier si l'app Mail est disponible
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            // Essayer d'ouvrir avec mailto:
            if let url = URL(string: "mailto:\(contactEmail)?subject=NGAP%20IDEL%20-%20Contact") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    showingMailError = true
                }
            } else {
                showingMailError = true
            }
        }
    }
    
    private func sendEmailToServer() {
        guard let email = userSettings.email, !email.isEmpty, isValidEmail(email) else { return }
        
        // TODO: Implémenter l'envoi vers votre backend/service d'emailing
        // Exemple avec un webhook ou API:
        /*
        let url = URL(string: "https://your-api.com/newsletter/subscribe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "source": "ngap_ios_app",
            "subscribed_at": ISO8601DateFormatter().string(from: Date())
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Gérer la réponse
        }.resume()
        */
        
        print("📧 Email à enregistrer: \(email)")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func exportData(format: ExportFormat) {
        // TODO: Implémenter l'export des favoris
        print("Export en \(format)")
    }
}

// MARK: - Export Format

enum ExportFormat {
    case pdf
    case csv
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Mail Composer View

struct MailComposerView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([recipient])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - Section Card

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.pastelLavandeDeep)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textMuted)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
    }
}

// MARK: - Direct Editable Row

struct DirectEditableRow: View {
    let icon: String
    let title: String
    @Binding var value: String?
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var onSubmit: (() -> Void)? = nil
    
    @State private var localValue: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.pastelLavandeDeep)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
                
                TextField(placeholder, text: $localValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textWarm)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .focused($isFocused)
                    .onChange(of: localValue) { _, newValue in
                        value = newValue.isEmpty ? nil : newValue
                    }
                    .onSubmit {
                        onSubmit?()
                    }
            }
            
            Spacer()
            
            // Indicateur de validation
            if let v = value, !v.isEmpty {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.pastelMentheDeep)
            } else {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(.textMuted.opacity(0.5))
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            localValue = value ?? ""
        }
    }
}

// MARK: - Tool Row

struct ToolRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textWarm)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.textMuted)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted.opacity(0.5))
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @StateObject private var userSettings = UserSettings.shared
    
    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            
            if userSettings.favoriteActIDs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.textMuted)
                    
                    Text("Aucun favori")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textWarm)
                    
                    Text("Ajoutez des actes en favoris\npour les retrouver ici")
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    Text("Liste des favoris à implémenter")
                        .padding()
                }
            }
        }
        .navigationTitle("Mes favoris")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Search History View

struct SearchHistoryView: View {
    @StateObject private var userSettings = UserSettings.shared
    
    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            
            if userSettings.searchHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 50))
                        .foregroundColor(.textMuted)
                    
                    Text("Aucun historique")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textWarm)
                    
                    Text("Vos recherches récentes\napparaîtront ici")
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                        .multilineTextAlignment(.center)
                }
            } else {
                List {
                    ForEach(userSettings.searchHistory, id: \.self) { query in
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textMuted)
                            
                            Text(query)
                                .foregroundColor(.textWarm)
                            
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        userSettings.searchHistory.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Historique")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !userSettings.searchHistory.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Effacer") {
                        userSettings.clearSearchHistory()
                    }
                    .foregroundColor(.pastelRoseDeep)
                }
            }
        }
    }
}

// MARK: - Legal View

struct LegalView: View {
    let contactEmail: String
    
    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // CGU
                    LegalSection(
                        title: "Conditions Générales d'Utilisation",
                        content: """
                        L'application NGAP IDEL est un outil d'aide à la cotation des actes infirmiers destiné aux infirmiers diplômés d'État exerçant en libéral (IDEL).
                        
                        Les informations fournies sont données à titre indicatif et ne sauraient se substituer aux textes officiels de la Nomenclature Générale des Actes Professionnels (NGAP).
                        
                        L'éditeur ne peut être tenu responsable des erreurs éventuelles ou des conséquences de l'utilisation des informations contenues dans l'application.
                        
                        L'utilisateur est invité à vérifier les cotations auprès des organismes officiels (CPAM, Assurance Maladie).
                        """
                    )
                    
                    // Confidentialité
                    LegalSection(
                        title: "Politique de Confidentialité",
                        content: """
                        Données collectées :
                        • Informations de profil (nom, cabinet, coordonnées) - stockées localement sur votre appareil
                        • Email (si inscription newsletter) - transmis à notre service d'emailing
                        • Données d'utilisation anonymisées pour améliorer l'application
                        
                        Vos données personnelles ne sont jamais vendues à des tiers.
                        
                        Vous pouvez à tout moment supprimer vos données depuis les paramètres de l'application.
                        """
                    )
                    
                    // Abonnement
                    LegalSection(
                        title: "Abonnement",
                        content: """
                        L'application propose un abonnement avec les conditions suivantes :
                        
                        • Essai gratuit de 7 jours
                        • Abonnement mensuel : 4,99 €/mois
                        • Abonnement annuel : 24,99 €/an
                        
                        Le paiement est prélevé sur votre compte Apple après la période d'essai.
                        
                        L'abonnement se renouvelle automatiquement sauf annulation au moins 24h avant la fin de la période en cours.
                        
                        Vous pouvez gérer votre abonnement dans les réglages de votre compte Apple.
                        """
                    )
                    
                    // Contact
                    LegalSection(
                        title: "Contact",
                        content: """
                        Pour toute question concernant l'application :
                        
                        Email : \(contactEmail)
                        
                        © 2026 NGAP IDEL - Tous droits réservés
                        """
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle("Mentions légales")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Legal Section

struct LegalSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textWarm)
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.textSoft)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    AccountView()
}
