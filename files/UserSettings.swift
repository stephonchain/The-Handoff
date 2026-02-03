import Foundation
import SwiftUI

// MARK: - User Settings

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    
    private enum Keys {
        static let nurseName = "nurseName"
        static let cabinetName = "cabinetName"
        static let cabinetAddress = "cabinetAddress"
        static let phone = "phone"
        static let email = "email"
        static let adeliNumber = "adeliNumber"
        static let newsletterEnabled = "newsletterEnabled"
        static let notificationsEnabled = "notificationsEnabled"
        static let hapticEnabled = "hapticEnabled"
        static let favoriteActIDs = "favoriteActIDs"
        static let searchHistory = "searchHistory"
        static let lastViewedCategory = "lastViewedCategory"
    }
    
    // MARK: - User Info
    
    @Published var nurseName: String? {
        didSet { defaults.set(nurseName, forKey: Keys.nurseName) }
    }
    
    @Published var cabinetName: String? {
        didSet { defaults.set(cabinetName, forKey: Keys.cabinetName) }
    }
    
    @Published var cabinetAddress: String? {
        didSet { defaults.set(cabinetAddress, forKey: Keys.cabinetAddress) }
    }
    
    @Published var phone: String? {
        didSet { defaults.set(phone, forKey: Keys.phone) }
    }
    
    @Published var email: String? {
        didSet { defaults.set(email, forKey: Keys.email) }
    }
    
    @Published var adeliNumber: String? {
        didSet { defaults.set(adeliNumber, forKey: Keys.adeliNumber) }
    }
    
    // MARK: - Preferences
    
    @Published var newsletterEnabled: Bool {
        didSet { defaults.set(newsletterEnabled, forKey: Keys.newsletterEnabled) }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }
    
    @Published var hapticEnabled: Bool {
        didSet { defaults.set(hapticEnabled, forKey: Keys.hapticEnabled) }
    }
    
    // MARK: - Favorites
    
    @Published var favoriteActIDs: [String] {
        didSet { defaults.set(favoriteActIDs, forKey: Keys.favoriteActIDs) }
    }
    
    // MARK: - Search History
    
    @Published var searchHistory: [String] {
        didSet {
            // Garder seulement les 20 dernières recherches
            let limited = Array(searchHistory.prefix(20))
            defaults.set(limited, forKey: Keys.searchHistory)
        }
    }
    
    // MARK: - Last Viewed
    
    @Published var lastViewedCategory: String? {
        didSet { defaults.set(lastViewedCategory, forKey: Keys.lastViewedCategory) }
    }
    
    // MARK: - Computed Properties
    
    var initials: String? {
        guard let name = nurseName, !name.isEmpty else { return nil }
        
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
    
    var hasUserInfo: Bool {
        nurseName != nil || cabinetName != nil || email != nil
    }
    
    // MARK: - Init
    
    init() {
        self.nurseName = defaults.string(forKey: Keys.nurseName)
        self.cabinetName = defaults.string(forKey: Keys.cabinetName)
        self.cabinetAddress = defaults.string(forKey: Keys.cabinetAddress)
        self.phone = defaults.string(forKey: Keys.phone)
        self.email = defaults.string(forKey: Keys.email)
        self.adeliNumber = defaults.string(forKey: Keys.adeliNumber)
        self.newsletterEnabled = defaults.bool(forKey: Keys.newsletterEnabled)
        self.notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        self.hapticEnabled = defaults.object(forKey: Keys.hapticEnabled) as? Bool ?? true
        self.favoriteActIDs = defaults.stringArray(forKey: Keys.favoriteActIDs) ?? []
        self.searchHistory = defaults.stringArray(forKey: Keys.searchHistory) ?? []
        self.lastViewedCategory = defaults.string(forKey: Keys.lastViewedCategory)
    }
    
    // MARK: - Methods
    
    func addToFavorites(_ actID: String) {
        if !favoriteActIDs.contains(actID) {
            favoriteActIDs.insert(actID, at: 0)
            triggerHaptic(.success)
        }
    }
    
    func removeFromFavorites(_ actID: String) {
        favoriteActIDs.removeAll { $0 == actID }
        triggerHaptic(.light)
    }
    
    func isFavorite(_ actID: String) -> Bool {
        favoriteActIDs.contains(actID)
    }
    
    func toggleFavorite(_ actID: String) {
        if isFavorite(actID) {
            removeFromFavorites(actID)
        } else {
            addToFavorites(actID)
        }
    }
    
    func addToSearchHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Retirer si déjà présent
        searchHistory.removeAll { $0.lowercased() == trimmed.lowercased() }
        
        // Ajouter en premier
        searchHistory.insert(trimmed, at: 0)
    }
    
    func clearSearchHistory() {
        searchHistory = []
    }
    
    func resetAll() {
        nurseName = nil
        cabinetName = nil
        cabinetAddress = nil
        phone = nil
        email = nil
        adeliNumber = nil
        newsletterEnabled = false
        notificationsEnabled = false
        hapticEnabled = true
        favoriteActIDs = []
        searchHistory = []
        lastViewedCategory = nil
        
        triggerHaptic(.warning)
    }
    
    // MARK: - Haptic
    
    func triggerHaptic(_ type: HapticType) {
        guard hapticEnabled else { return }
        
        switch type {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    enum HapticType {
        case light, medium, success, warning, error, selection
    }
}

// MARK: - Export Manager

class ExportManager {
    static let shared = ExportManager()
    
    func exportFavoritesToPDF(acts: [Act]) -> URL? {
        // TODO: Implémenter l'export PDF
        return nil
    }
    
    func exportFavoritesToCSV(acts: [Act]) -> URL? {
        // TODO: Implémenter l'export CSV
        return nil
    }
    
    func generateInvoiceData(acts: [Act], quantities: [String: Int]) -> String {
        var csv = "Code,Acte,Coefficient,Quantité,Tarif unitaire,Total\n"
        
        for act in acts {
            let qty = quantities[act.id.uuidString] ?? 1
            let price = Tarifs.calculatePrice(for: act)
            csv += "\(act.code),\"\(act.title)\",\(act.coef),\(qty),\(price),\(price)\n"
        }
        
        return csv
    }
}
