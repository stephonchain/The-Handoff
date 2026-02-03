import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var trialManager = TrialManager.shared
    @StateObject private var userSettings = UserSettings.shared
    
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedAct: Act?
    @State private var showingActList = false
    @State private var showingPaywall = false
    @State private var showingAccount = false
    
    var canAccessContent: Bool {
        trialManager.isTrialActive || storeManager.hasActiveSubscription
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgCream
                    .ignoresSafeArea()
                
                // Gradient overlays
                GeometryReader { geo in
                    Circle()
                        .fill(Color.pastelRose.opacity(0.15))
                        .frame(width: geo.size.width * 0.8)
                        .offset(x: -geo.size.width * 0.3, y: -geo.size.height * 0.1)
                    
                    Circle()
                        .fill(Color.pastelMenthe.opacity(0.15))
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.7)
                    
                    Circle()
                        .fill(Color.pastelLavande.opacity(0.1))
                        .frame(width: geo.size.width * 0.5)
                        .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.3)
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Trial/Subscription Banner
                        if !storeManager.hasActiveSubscription {
                            subscriptionBanner
                                .padding(.horizontal)
                        }
                        
                        // Search
                        searchBar
                            .padding(.horizontal)
                        
                        if !searchText.isEmpty {
                            // Search Results
                            searchResultsView
                        } else {
                            // Categories Grid
                            categoriesGrid
                                .padding(.horizontal)
                            
                            // Quick Reference
                            quickReferenceCard
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $showingActList) {
                if let category = selectedCategory {
                    ActListView(category: category, dataStore: dataStore)
                }
            }
            .sheet(item: $selectedAct) { act in
                ActDetailSheet(act: act)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAccount) {
                AccountView()
            }
        }
        .onAppear {
            trialManager.checkTrialStatus()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        ZStack {
            LinearGradient(
                colors: [.pastelRose, .pastelLavande, .pastelCiel],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 150)
                .offset(x: 100, y: -50)
            
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 100)
                .offset(x: -80, y: 30)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NGAP IDEL")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text("Titre XVI - Edition 2025 ✨")
                        .font(.custom("Marker Felt", size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Account Button
                Button(action: { showingAccount = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 44, height: 44)
                        
                        if let initials = userSettings.initials {
                            Text(initials)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        
                        // Pro badge
                        if storeManager.hasActiveSubscription {
                            Circle()
                                .fill(Color.pastelMentheDeep)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 14, y: -14)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    // MARK: - Subscription Banner
    
    private var subscriptionBanner: some View {
        Button(action: {
            showingPaywall = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 44, height: 44)
                    
                    if trialManager.isTrialActive {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if trialManager.isTrialActive {
                        Text("Essai gratuit en cours")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(trialManager.daysRemaining) jour\(trialManager.daysRemaining > 1 ? "s" : "") restant\(trialManager.daysRemaining > 1 ? "s" : "")")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    } else if trialManager.hasUsedTrial {
                        Text("Votre essai est terminé")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Passez à Pro pour continuer")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        Text("7 jours d'essai gratuit")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Accédez à tous les actes NGAP")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: trialManager.isTrialActive 
                        ? [.pastelMentheDeep, .pastelCielDeep]
                        : [.pastelLavandeDeep, .pastelRoseDeep],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .pastelLavandeDeep.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.pastelLavandeDeep)
                .font(.system(size: 18, weight: .medium))
            
            TextField("Rechercher un acte...", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textWarm)
                .onSubmit {
                    if !searchText.isEmpty {
                        userSettings.addToSearchHistory(searchText)
                    }
                }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .offset(y: -10)
    }
    
    // MARK: - Search Results
    
    private var searchResultsView: some View {
        let results = dataStore.searchActs(searchText)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Résultats")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.textWarm)
                
                Spacer()
                
                Text("\(results.count) résultat\(results.count > 1 ? "s" : "")")
                    .font(.custom("Marker Felt", size: 16))
                    .foregroundColor(.textMuted)
            }
            .padding(.horizontal)
            
            if results.isEmpty {
                VStack(spacing: 16) {
                    Text("🔍")
                        .font(.system(size: 60))
                    Text("Aucun résultat")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textSoft)
                    Text("Essayez avec d'autres termes")
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(results) { act in
                        ActCard(act: act)
                            .onTapGesture {
                                handleActTap(act)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Categories Grid
    
    private var categoriesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(dataStore.categories) { category in
                CategoryCard(
                    category: category, 
                    actCount: dataStore.actsForCategory(category.id).count,
                    isLocked: !canAccessContent
                )
                .onTapGesture {
                    handleCategoryTap(category)
                }
            }
        }
    }
    
    // MARK: - Quick Reference
    
    private var quickReferenceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💡 Tarifs de base")
                .font(.custom("Marker Felt", size: 20))
                .foregroundColor(.pastelLavandeDeep)
            
            HStack(spacing: 12) {
                QuickRefItem(label: "IFD", value: "2,75 €", color: .pastelRose)
                QuickRefItem(label: "AMI", value: "3,15 €", color: .pastelMenthe)
                QuickRefItem(label: "MCI", value: "5,00 €", color: .pastelLavande)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Actions
    
    private func handleCategoryTap(_ category: Category) {
        userSettings.triggerHaptic(.selection)
        userSettings.lastViewedCategory = category.id
        
        if canAccessContent {
            selectedCategory = category
            showingActList = true
        } else {
            showingPaywall = true
        }
    }
    
    private func handleActTap(_ act: Act) {
        userSettings.triggerHaptic(.light)
        
        if canAccessContent {
            selectedAct = act
        } else {
            showingPaywall = true
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: Category
    let actCount: Int
    var isLocked: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(category.color.opacity(isLocked ? 0.15 : 0.3))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isLocked ? .textMuted : (category.gradientColors.last ?? category.color))
                }
                
                Text(category.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isLocked ? .textMuted : .textWarm)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text("\(actCount) actes")
                    .font(.custom("Marker Felt", size: 12))
                    .foregroundColor(.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(isLocked ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                VStack {
                    LinearGradient(colors: category.gradientColors.map { isLocked ? $0.opacity(0.3) : $0 }, startPoint: .leading, endPoint: .trailing)
                        .frame(height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            
            // Lock icon
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.textMuted)
                    .clipShape(Circle())
                    .offset(x: -8, y: 8)
            }
        }
    }
}

// MARK: - Quick Ref Item

struct QuickRefItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.textSoft)
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.textWarm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Act Card

struct ActCard: View {
    let act: Act
    @StateObject private var userSettings = UserSettings.shared
    
    var isNR: Bool {
        act.code == "NR"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(act.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.textWarm)
                    .lineLimit(2)
                
                if !act.notes.isEmpty {
                    Text(act.notes)
                        .font(.system(size: 12))
                        .foregroundColor(.textMuted)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(act.code)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(isNR ? .pastelPecheDeep : .pastelLavandeDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isNR ? Color.pastelPeche.opacity(0.3) : Color.pastelLavande.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(isNR ? "Non remb." : "~\(Tarifs.calculatePrice(for: act))")
                    .font(.custom("Marker Felt", size: 13))
                    .foregroundColor(.textMuted)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
