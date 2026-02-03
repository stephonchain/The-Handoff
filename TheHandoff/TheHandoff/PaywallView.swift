import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var trialManager = TrialManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    
    enum PlanType {
        case monthly, yearly
    }
    
    // Prix (utilisés si StoreKit ne charge pas les produits)
    let monthlyPrice = "4,99 €"
    let yearlyPrice = "24,99 €"
    let yearlyMonthlyEquivalent = "2,08 €"
    let savingsPercent = "58%"
    
    // URLs légales - MODIFIER AVEC VOS URLS
    let privacyURL = URL(string: "https://stephonchain.github.io/ngap-legal/privacy.html")!
    let termsURL = URL(string: "https://stephonchain.github.io/ngap-legal/terms.html")!
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Close button
                    closeButton
                    
                    // Hero
                    heroSection
                        .padding(.top, 8)
                    
                    // Features
                    featuresSection
                        .padding(.top, 32)
                    
                    // Pricing
                    pricingSection
                        .padding(.top, 32)
                    
                    // CTA Button
                    ctaButton
                        .padding(.top, 24)
                    
                    // Trial info
                    trialInfo
                        .padding(.top, 16)
                    
                    // Subscription details (REQUIS PAR APPLE)
                    subscriptionDetails
                        .padding(.top, 20)
                    
                    // Restore & Legal
                    footerSection
                        .padding(.top, 24)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            
            // Loading
            if storeManager.isLoading || isPurchasing {
                loadingOverlay
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            
            // Decorative blobs
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.pastelRose.opacity(0.4), Color.pastelRose.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.5
                        )
                    )
                    .frame(width: geo.size.width * 0.8)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.pastelLavande.opacity(0.3), Color.pastelLavande.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.4
                        )
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.15)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.pastelMenthe.opacity(0.25), Color.pastelMenthe.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.35
                        )
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: geo.size.width * 0.1, y: geo.size.height * 0.6)
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Close Button
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textMuted)
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            // App Icon
            ZStack {
                // Glow
                Circle()
                    .fill(Color.pastelLavande.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [.pastelRose, .pastelLavande, .pastelCiel],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .pastelLavande.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
            }
            
            // Title & Subtitle
            VStack(spacing: 8) {
                Text("Passez à Pro")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.textWarm)
                
                Text("Accès illimité à toute la nomenclature NGAP")
                    .font(.system(size: 16))
                    .foregroundColor(.textSoft)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureItem(
                icon: "checkmark.seal.fill",
                iconColor: .pastelMentheDeep,
                title: "123 actes complets",
                subtitle: "Toute la nomenclature Titre XVI"
            )
            
            FeatureItem(
                icon: "magnifyingglass",
                iconColor: .pastelCielDeep,
                title: "Recherche instantanée",
                subtitle: "Trouvez n'importe quel acte en 2 secondes"
            )
            
            FeatureItem(
                icon: "eurosign.circle.fill",
                iconColor: .pastelSoleilDeep,
                title: "Calcul automatique",
                subtitle: "Tarifs toujours à jour"
            )
            
            FeatureItem(
                icon: "icloud.fill",
                iconColor: .pastelLavandeDeep,
                title: "Mises à jour incluses",
                subtitle: "Nouvelles cotations dès leur parution"
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 8)
        )
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        VStack(spacing: 12) {
            // Yearly Plan (Recommended)
            PlanCard(
                isSelected: selectedPlan == .yearly,
                badge: "ÉCONOMISEZ \(savingsPercent)",
                title: "Annuel",
                price: storeManager.yearlyProduct?.displayPrice ?? yearlyPrice,
                period: "/an",
                detail: "soit \(yearlyMonthlyEquivalent)/mois",
                onTap: { withAnimation(.spring(response: 0.3)) { selectedPlan = .yearly } }
            )
            
            // Monthly Plan
            PlanCard(
                isSelected: selectedPlan == .monthly,
                badge: nil,
                title: "Mensuel",
                price: storeManager.monthlyProduct?.displayPrice ?? monthlyPrice,
                period: "/mois",
                detail: "Sans engagement",
                onTap: { withAnimation(.spring(response: 0.3)) { selectedPlan = .monthly } }
            )
        }
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        Button(action: {
            Task { await subscribe() }
        }) {
            HStack(spacing: 8) {
                Text("Commencer l'essai gratuit")
                    .font(.system(size: 18, weight: .bold))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 139/255, green: 92/255, blue: 246/255),
                        Color(red: 236/255, green: 72/255, blue: 153/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.pastelLavandeDeep.opacity(0.4), radius: 16, x: 0, y: 8)
        }
    }
    
    // MARK: - Trial Info
    
    private var trialInfo: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.pastelMentheDeep)
                
                Text("7 jours gratuits")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.pastelMentheDeep)
            }
            
            Text("puis \(selectedPlan == .yearly ? (storeManager.yearlyProduct?.displayPrice ?? yearlyPrice) + "/an" : (storeManager.monthlyProduct?.displayPrice ?? monthlyPrice) + "/mois"). Annulez à tout moment.")
                .font(.system(size: 13))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.pastelMenthe.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.pastelMentheDeep.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Subscription Details (REQUIS PAR APPLE)
    
    private var subscriptionDetails: some View {
        VStack(spacing: 12) {
            Text("Détails de l'abonnement")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted)
                .textCase(.uppercase)
            
            VStack(spacing: 8) {
                // Abonnement sélectionné
                HStack {
                    Text("Abonnement")
                    Spacer()
                    Text(selectedPlan == .yearly ? "NGAP Pro Annuel" : "NGAP Pro Mensuel")
                        .fontWeight(.medium)
                }
                .font(.system(size: 13))
                .foregroundColor(.textSoft)
                
                // Durée
                HStack {
                    Text("Durée")
                    Spacer()
                    Text(selectedPlan == .yearly ? "1 an" : "1 mois")
                        .fontWeight(.medium)
                }
                .font(.system(size: 13))
                .foregroundColor(.textSoft)
                
                // Prix
                HStack {
                    Text("Prix")
                    Spacer()
                    Text(selectedPlan == .yearly ? (storeManager.yearlyProduct?.displayPrice ?? yearlyPrice) : (storeManager.monthlyProduct?.displayPrice ?? monthlyPrice))
                        .fontWeight(.medium)
                }
                .font(.system(size: 13))
                .foregroundColor(.textSoft)
                
                // Essai gratuit
                HStack {
                    Text("Essai gratuit")
                    Spacer()
                    Text("7 jours")
                        .fontWeight(.medium)
                }
                .font(.system(size: 13))
                .foregroundColor(.textSoft)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Texte légal avec renouvellement
            Text("L'abonnement se renouvelle automatiquement sauf annulation au moins 24h avant la fin de la période. Le paiement sera prélevé sur votre compte Apple.")
                .font(.system(size: 11))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Footer
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            // Restore
            Button(action: {
                Task {
                    await storeManager.restorePurchases()
                    if storeManager.hasActiveSubscription {
                        dismiss()
                    }
                }
            }) {
                Text("Restaurer mes achats")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSoft)
                    .underline()
            }
            
            // LIENS LÉGAUX FONCTIONNELS (REQUIS PAR APPLE)
            HStack(spacing: 20) {
                Link(destination: termsURL) {
                    Text("Conditions d'utilisation")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.pastelLavandeDeep)
                        .underline()
                }
                
                Text("•")
                    .foregroundColor(.textMuted)
                
                Link(destination: privacyURL) {
                    Text("Politique de confidentialité")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.pastelLavandeDeep)
                        .underline()
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.white)
                
                Text("Chargement...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.textWarm.opacity(0.95))
            )
        }
    }
    
    // MARK: - Actions
    
    private func subscribe() async {
        isPurchasing = true
        
        let product: Product?
        if selectedPlan == .yearly {
            product = storeManager.yearlyProduct
        } else {
            product = storeManager.monthlyProduct
        }
        
        if let product = product {
            let success = await storeManager.purchase(product)
            if success {
                dismiss()
            }
        } else {
            // Fallback: démarrer trial local si pas de produits
            trialManager.startTrial()
            dismiss()
        }
        
        isPurchasing = false
    }
}

// MARK: - Feature Item

struct FeatureItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textWarm)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.textMuted)
            }
            
            Spacer()
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let isSelected: Bool
    let badge: String?
    let title: String
    let price: String
    let period: String
    let detail: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.pastelLavandeDeep : Color.textMuted.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.pastelLavandeDeep)
                            .frame(width: 14, height: 14)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.textWarm)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.pastelPecheDeep, .pastelRoseDeep],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(detail)
                        .font(.system(size: 13))
                        .foregroundColor(.textMuted)
                }
                
                Spacer()
                
                // Price
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.textWarm)
                    
                    Text(period)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textMuted)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.pastelLavande.opacity(0.12) : Color.white)
                    .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected 
                            ? LinearGradient(colors: [.pastelLavandeDeep, .pastelRoseDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}
