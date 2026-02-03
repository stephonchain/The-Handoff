import Foundation
import StoreKit

// MARK: - Product IDs

enum ProductID: String, CaseIterable {
    case monthly = "com.ngap.subscription.monthly"    // 4,99€/mois
    case yearly = "com.ngap.subscription.yearly"      // 24,99€/an
    
    var displayName: String {
        switch self {
        case .monthly: return "Mensuel"
        case .yearly: return "Annuel"
        }
    }
}

// MARK: - Store Manager

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    var monthlyProduct: Product? {
        products.first { $0.id == ProductID.monthly.rawValue }
    }
    
    var yearlyProduct: Product? {
        products.first { $0.id == ProductID.yearly.rawValue }
    }
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        isLoading = true
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = "Impossible de charger les produits: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                isLoading = false
                return true
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                errorMessage = "Achat en attente d'approbation"
                isLoading = false
                return false
                
            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Erreur lors de l'achat: \(error.localizedDescription)"
            print("Purchase failed: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Impossible de restaurer les achats: \(error.localizedDescription)"
            print("Restore failed: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Update Purchased Products
    
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    await self?.updatePurchasedProducts()
                    await transaction?.finish()
                } catch {
                    print("Transaction listener error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verification
    
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
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
            return "La vérification de l'achat a échoué"
        case .purchaseFailed:
            return "L'achat a échoué"
        }
    }
}

// MARK: - Trial Manager

class TrialManager: ObservableObject {
    static let shared = TrialManager()
    
    private let trialStartKey = "trialStartDate"
    private let trialDurationDays = 7
    
    @Published var isTrialActive: Bool = false
    @Published var daysRemaining: Int = 0
    
    init() {
        checkTrialStatus()
    }
    
    var trialStartDate: Date? {
        get {
            UserDefaults.standard.object(forKey: trialStartKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: trialStartKey)
        }
    }
    
    func startTrial() {
        if trialStartDate == nil {
            trialStartDate = Date()
        }
        checkTrialStatus()
    }
    
    func checkTrialStatus() {
        guard let startDate = trialStartDate else {
            isTrialActive = false
            daysRemaining = trialDurationDays
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: trialDurationDays, to: startDate)!
        
        if now < endDate {
            isTrialActive = true
            let remaining = calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
            daysRemaining = max(0, remaining)
        } else {
            isTrialActive = false
            daysRemaining = 0
        }
    }
    
    var hasUsedTrial: Bool {
        trialStartDate != nil
    }
}
