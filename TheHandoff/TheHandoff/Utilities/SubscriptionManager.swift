import Foundation
import StoreKit

// MARK: - Product IDs
enum SubscriptionProduct: String, CaseIterable {
    case monthly = "com.handoff.subscription.monthly"
    case yearly = "com.handoff.subscription.yearly"
    case lifetime = "com.handoff.lifetime"

    var isSubscription: Bool {
        self != .lifetime
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: Equatable {
    case notSubscribed
    case subscribed(expirationDate: Date?)
    case lifetime
    case inTrial(expirationDate: Date)

    var isActive: Bool {
        switch self {
        case .notSubscribed:
            return false
        case .subscribed, .lifetime, .inTrial:
            return true
        }
    }

    var isPremium: Bool {
        isActive
    }
}

// MARK: - Subscription Manager
@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed
    private(set) var isLoading = false

    private var updateListenerTask: Task<Void, Error>?

    var monthlyProduct: Product? {
        products.first { $0.id == SubscriptionProduct.monthly.rawValue }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == SubscriptionProduct.yearly.rawValue }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == SubscriptionProduct.lifetime.rawValue }
    }

    var isPremium: Bool {
        subscriptionStatus.isPremium
    }

    private init() {
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products
    @MainActor
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIDs = SubscriptionProduct.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            products.sort { product1, product2 in
                product1.price < product2.price
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore Purchases
    @MainActor
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    // MARK: - Update Subscription Status
    @MainActor
    func updateSubscriptionStatus() async {
        var hasLifetime = false
        var latestSubscription: (expirationDate: Date?, isInTrial: Bool)? = nil

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.productID == SubscriptionProduct.lifetime.rawValue {
                hasLifetime = true
                purchasedProductIDs.insert(transaction.productID)
            } else if transaction.productType == .autoRenewable {
                purchasedProductIDs.insert(transaction.productID)

                let isInTrial = transaction.offerType == .introductory

                if let existing = latestSubscription {
                    if let existingDate = existing.expirationDate,
                       let newDate = transaction.expirationDate,
                       newDate > existingDate {
                        latestSubscription = (transaction.expirationDate, isInTrial)
                    }
                } else {
                    latestSubscription = (transaction.expirationDate, isInTrial)
                }
            }
        }

        if hasLifetime {
            subscriptionStatus = .lifetime
        } else if let subscription = latestSubscription {
            if subscription.isInTrial, let expirationDate = subscription.expirationDate {
                subscriptionStatus = .inTrial(expirationDate: expirationDate)
            } else {
                subscriptionStatus = .subscribed(expirationDate: subscription.expirationDate)
            }
        } else {
            subscriptionStatus = .notSubscribed
        }
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self.updateSubscriptionStatus()
                await transaction.finish()
            }
        }
    }

    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Error
enum StoreError: Error, LocalizedError {
    case verificationFailed
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "La vérification de l'achat a échoué."
        case .purchaseFailed:
            return "L'achat n'a pas pu être complété."
        }
    }
}

// MARK: - Product Extensions
extension Product {
    var localizedPricePerMonth: String {
        guard let subscription = self.subscription else {
            return displayPrice
        }

        let monthlyPrice: Decimal
        switch subscription.subscriptionPeriod.unit {
        case .year:
            monthlyPrice = price / Decimal(subscription.subscriptionPeriod.value * 12)
        case .month:
            monthlyPrice = price / Decimal(subscription.subscriptionPeriod.value)
        case .week:
            monthlyPrice = price * Decimal(4) / Decimal(subscription.subscriptionPeriod.value)
        case .day:
            monthlyPrice = price * Decimal(30) / Decimal(subscription.subscriptionPeriod.value)
        @unknown default:
            monthlyPrice = price
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceFormatStyle.locale

        return formatter.string(from: monthlyPrice as NSDecimalNumber) ?? displayPrice
    }

    var trialPeriodText: String? {
        guard let introductoryOffer = subscription?.introductoryOffer,
              introductoryOffer.paymentMode == .freeTrial else {
            return nil
        }

        let period = introductoryOffer.period
        switch period.unit {
        case .day:
            return period.value == 1 ? "1 jour d'essai gratuit" : "\(period.value) jours d'essai gratuit"
        case .week:
            return period.value == 1 ? "1 semaine d'essai gratuit" : "\(period.value) semaines d'essai gratuit"
        case .month:
            return period.value == 1 ? "1 mois d'essai gratuit" : "\(period.value) mois d'essai gratuit"
        case .year:
            return period.value == 1 ? "1 an d'essai gratuit" : "\(period.value) ans d'essai gratuit"
        @unknown default:
            return nil
        }
    }

    var periodText: String {
        guard let subscription = self.subscription else {
            return "À vie"
        }

        switch subscription.subscriptionPeriod.unit {
        case .day:
            return "par jour"
        case .week:
            return "par semaine"
        case .month:
            return "par mois"
        case .year:
            return "par an"
        @unknown default:
            return ""
        }
    }
}
