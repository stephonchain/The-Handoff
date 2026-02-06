import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let features = [
        ("checkmark.circle.fill", "Check-ins illimités", "Avant et après chaque shift"),
        ("book.fill", "Journal complet", "Photos, audio et entrées illimitées"),
        ("chart.line.uptrend.xyaxis", "Statistiques détaillées", "Analyse de ton bien-être"),
        ("trophy.fill", "Tous les badges", "Débloque tous les accomplissements"),
        ("bell.badge.fill", "Rappels personnalisés", "Ne manque jamais un check-in")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    featuresSection

                    productsSection

                    trialBadge

                    purchaseButton

                    legalSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if let yearly = subscriptionManager.yearlyProduct {
                selectedProduct = yearly
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            .padding(.top, 20)

            VStack(spacing: 8) {
                Text("Handoff Premium")
                    .font(.title.bold())

                Text("Prends soin de toi, sans limites")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(features, id: \.0) { icon, title, subtitle in
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(Color(hex: "F59E0B"))
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))

                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Products
    private var productsSection: some View {
        VStack(spacing: 12) {
            if subscriptionManager.isLoading && subscriptionManager.products.isEmpty {
                ProgressView()
                    .padding(.vertical, 40)
            } else {
                // Yearly - Best Value
                if let yearly = subscriptionManager.yearlyProduct {
                    ProductCard(
                        product: yearly,
                        isSelected: selectedProduct?.id == yearly.id,
                        badge: "Meilleure offre",
                        savingsText: savingsText(for: yearly)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedProduct = yearly
                        }
                        HapticManager.shared.impact(style: .light)
                    }
                }

                // Monthly
                if let monthly = subscriptionManager.monthlyProduct {
                    ProductCard(
                        product: monthly,
                        isSelected: selectedProduct?.id == monthly.id,
                        badge: nil,
                        savingsText: nil
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedProduct = monthly
                        }
                        HapticManager.shared.impact(style: .light)
                    }
                }

                // Lifetime
                if let lifetime = subscriptionManager.lifetimeProduct {
                    ProductCard(
                        product: lifetime,
                        isSelected: selectedProduct?.id == lifetime.id,
                        badge: "Paiement unique",
                        savingsText: nil,
                        isLifetime: true
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedProduct = lifetime
                        }
                        HapticManager.shared.impact(style: .light)
                    }
                }
            }
        }
    }

    // MARK: - Trial Badge
    @ViewBuilder
    private var trialBadge: some View {
        if let product = selectedProduct,
           let trialText = product.trialPeriodText {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(Color(hex: "10B981"))

                Text(trialText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: "10B981"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: "10B981").opacity(0.1))
            .clipShape(Capsule())
        }
    }

    // MARK: - Purchase Button
    private var purchaseButton: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await purchase()
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(purchaseButtonText)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedProduct == nil || isPurchasing)

            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Text("Restaurer mes achats")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var purchaseButtonText: String {
        guard let product = selectedProduct else {
            return "Sélectionner une offre"
        }

        if product.trialPeriodText != nil {
            return "Commencer l'essai gratuit"
        } else if product.id == SubscriptionProduct.lifetime.rawValue {
            return "Acheter \(product.displayPrice)"
        } else {
            return "S'abonner pour \(product.displayPrice)"
        }
    }

    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("L'abonnement se renouvelle automatiquement sauf annulation au moins 24h avant la fin de la période en cours. Le paiement sera débité sur votre compte Apple.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Conditions d'utilisation", destination: URL(string: "https://stephonchain.github.io/The-Handoff/terms.html")!)
                Link("Confidentialité", destination: URL(string: "https://stephonchain.github.io/The-Handoff/privacy.html")!)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers
    private func savingsText(for product: Product) -> String? {
        guard let monthly = subscriptionManager.monthlyProduct,
              let yearlySubscription = product.subscription,
              yearlySubscription.subscriptionPeriod.unit == .year else {
            return nil
        }

        let yearlyTotal = product.price
        let monthlyTotal = monthly.price * 12
        let savings = monthlyTotal - yearlyTotal
        let percentage = Int((savings / monthlyTotal) * 100)

        return "Économise \(percentage)%"
    }

    private func purchase() async {
        guard let product = selectedProduct else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let success = try await subscriptionManager.purchase(product)
            if success {
                HapticManager.shared.notification(type: .success)
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            HapticManager.shared.notification(type: .error)
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let savingsText: String?
    var isLifetime: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "F59E0B") : Color(.tertiaryLabel), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color(hex: "F59E0B"))
                            .frame(width: 16, height: 16)
                    }
                }

                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(productTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "F59E0B"))
                                .clipShape(Capsule())
                        }
                    }

                    if let savingsText {
                        Text(savingsText)
                            .font(.caption)
                            .foregroundStyle(Color(hex: "10B981"))
                    }
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if !isLifetime {
                        Text(product.periodText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var productTitle: String {
        if isLifetime {
            return "Accès à vie"
        }

        guard let subscription = product.subscription else {
            return product.displayName
        }

        switch subscription.subscriptionPeriod.unit {
        case .month:
            return "Mensuel"
        case .year:
            return "Annuel"
        default:
            return product.displayName
        }
    }
}

#Preview {
    PaywallView()
}
