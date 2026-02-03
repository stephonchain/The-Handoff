# ShiftMood - SwiftUI Architecture

---

## Project Structure

```
ShiftMoodApp/
├── ShiftMoodApp.swift (App entry point)
├── ContentView.swift (Tab container)
│
├── Models/
│   ├── UserProfile.swift
│   ├── Shift.swift
│   ├── Mood.swift
│   ├── JournalEntry.swift
│   ├── Vacation.swift
│   ├── DailyAffirmation.swift
│   └── Enums/
│       ├── ShiftType.swift
│       ├── VacationType.swift
│       ├── AffirmationCategory.swift
│       └── MoodBadge.swift
│
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── JournalViewModel.swift
│   ├── MoodViewModel.swift
│   ├── VacationViewModel.swift
│   └── AffirmationViewModel.swift
│
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── WelcomeView.swift
│   │   ├── NameInputView.swift
│   │   └── VacationSetupView.swift
│   │
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── AffirmationCard.swift
│   │   ├── VacationCountdownCard.swift
│   │   └── QuickActionsView.swift
│   │
│   ├── Journal/
│   │   ├── JournalListView.swift
│   │   ├── JournalDetailView.swift
│   │   ├── JournalEditView.swift
│   │   └── NewJournalView.swift
│   │
│   ├── Mood/
│   │   ├── CheckInView.swift
│   │   ├── CheckOutView.swift
│   │   └── MoodSummaryView.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── VacationManagementView.swift
│   │   └── AboutView.swift
│   │
│   └── Stats/
│       └── StatsPlaceholderView.swift
│
├── Components/
│   ├── MoodSlider.swift
│   ├── EmojiMoodSelector.swift
│   ├── TagChipView.swift
│   ├── JournalEntryRow.swift
│   └── EmptyStateView.swift
│
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── View+Extensions.swift
│   └── Helpers/
│       ├── HapticManager.swift
│       ├── DateFormatter+Shared.swift
│       └── VacationCalculator.swift
│
├── Resources/
│   ├── Affirmations.json
│   ├── Assets.xcassets/
│   └── Localizable.strings
│
└── Preview Content/
    └── PreviewData.swift
```

---

## SwiftData Schema

### Core Models with Relationships

```swift
import SwiftData
import Foundation

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var createdAt: Date
    var onboardingCompleted: Bool
    
    init(firstName: String) {
        self.id = UUID()
        self.firstName = firstName
        self.createdAt = Date()
        self.onboardingCompleted = false
    }
}

@Model
final class Shift {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: ShiftType
    var preMood: Mood?
    var postMood: Mood?
    var startTime: Date?
    var endTime: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.shift)
    var journalEntries: [JournalEntry]?
    
    init(date: Date, type: ShiftType) {
        self.id = UUID()
        self.date = date
        self.type = type
    }
    
    var duration: TimeInterval? {
        guard let start = startTime, let end = endTime else { return nil }
        return end.timeIntervalSince(start)
    }
}

@Model
final class Mood {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var energy: Int // 1-5
    var stress: Int // 1-5
    var motivation: Int // 1-5
    var emotionalLoad: Int? // 1-5 (post-shift)
    var fatigue: Int? // 1-5 (post-shift)
    var satisfaction: Int? // 1-5 (post-shift)
    var badges: [String] // Emoji unicode strings
    var notes: String?
    
    init(energy: Int, stress: Int, motivation: Int) {
        self.id = UUID()
        self.timestamp = Date()
        self.energy = energy
        self.stress = stress
        self.motivation = motivation
        self.badges = []
    }
}

@Model
final class JournalEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var moodEmoji: String
    var tags: [String]
    var highlights: [String]
    var createdAt: Date
    var modifiedAt: Date
    
    @Relationship var shift: Shift?
    
    init(title: String, content: String, moodEmoji: String = "😊") {
        self.id = UUID()
        self.title = title
        self.content = content
        self.moodEmoji = moodEmoji
        self.tags = []
        self.highlights = []
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

@Model
final class Vacation {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var type: VacationType
    var status: VacationStatus
    
    init(startDate: Date, endDate: Date, type: VacationType = .congés) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.status = .planifié
    }
    
    var daysCount: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

@Model
final class DailyAffirmation {
    @Attribute(.unique) var id: UUID
    var text: String
    var category: AffirmationCategory
    var shownDate: Date?
    var liked: Bool
    
    init(text: String, category: AffirmationCategory) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.liked = false
    }
}
```

---

## Enums

```swift
// ShiftType.swift
enum ShiftType: String, Codable, CaseIterable {
    case jour = "Jour"
    case nuit = "Nuit"
    case repos = "Repos"
    
    var icon: String {
        switch self {
        case .jour: return "sun.max.fill"
        case .nuit: return "moon.stars.fill"
        case .repos: return "bed.double.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .jour: return .blue
        case .nuit: return .purple
        case .repos: return .green
        }
    }
}

// VacationType.swift
enum VacationType: String, Codable, CaseIterable {
    case congés = "Congés"
    case rtt = "RTT"
    case formation = "Formation"
}

enum VacationStatus: String, Codable {
    case planifié = "Planifié"
    case validé = "Validé"
    case enCours = "En cours"
    case terminé = "Terminé"
}

// AffirmationCategory.swift
enum AffirmationCategory: String, Codable, CaseIterable {
    case resilience = "Résilience"
    case competence = "Compétence"
    case compassion = "Compassion"
    case balance = "Équilibre"
    
    var color: Color {
        switch self {
        case .resilience: return Color(hex: "F59E0B")
        case .competence: return Color(hex: "8B5CF6")
        case .compassion: return Color(hex: "10B981")
        case .balance: return Color(hex: "3B82F6")
        }
    }
}

// MoodBadge.swift
enum MoodBadge: String, CaseIterable {
    case happy = "😊"
    case sad = "😔"
    case calm = "😌"
    case anxious = "😰"
    case proud = "💪"
    case tired = "😴"
    case frustrated = "😤"
    case grateful = "🙏"
    
    var label: String {
        switch self {
        case .happy: return "Content(e)"
        case .sad: return "Triste"
        case .calm: return "Calme"
        case .anxious: return "Anxieux(se)"
        case .proud: return "Fier(ère)"
        case .tired: return "Fatigué(e)"
        case .frustrated: return "Frustré(e)"
        case .grateful: return "Reconnaissant(e)"
        }
    }
}
```

---

## MVVM Pattern

### Example: HomeViewModel

```swift
import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var userProfile: UserProfile?
    var todayAffirmation: DailyAffirmation?
    var nextVacation: Vacation?
    var upcomingShift: Shift?
    var daysUntilVacation: Int = 0
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() async {
        await fetchUserProfile()
        await fetchTodayAffirmation()
        await fetchNextVacation()
        calculateVacationCountdown()
    }
    
    @MainActor
    private func fetchUserProfile() async {
        let descriptor = FetchDescriptor<UserProfile>()
        userProfile = try? modelContext.fetch(descriptor).first
    }
    
    @MainActor
    private func fetchTodayAffirmation() async {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyAffirmation>(
            predicate: #Predicate { $0.shownDate == today }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            todayAffirmation = existing
        } else {
            // Generate new affirmation for today
            todayAffirmation = await generateTodayAffirmation()
        }
    }
    
    @MainActor
    private func fetchNextVacation() async {
        let now = Date()
        let descriptor = FetchDescriptor<Vacation>(
            predicate: #Predicate { $0.startDate > now },
            sortBy: [SortDescriptor(\.startDate)]
        )
        nextVacation = try? modelContext.fetch(descriptor).first
    }
    
    private func calculateVacationCountdown() {
        guard let vacation = nextVacation else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let vacationStart = calendar.startOfDay(for: vacation.startDate)
        
        if let days = calendar.dateComponents([.day], from: today, to: vacationStart).day {
            daysUntilVacation = max(0, days)
        }
    }
    
    private func generateTodayAffirmation() async -> DailyAffirmation {
        // Load affirmations from JSON or database
        let allAffirmations = AffirmationService.shared.getAllAffirmations()
        
        // Select affirmation based on day of year (deterministic rotation)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % allAffirmations.count
        let selected = allAffirmations[index]
        
        let affirmation = DailyAffirmation(text: selected.text, category: selected.category)
        affirmation.shownDate = Calendar.current.startOfDay(for: Date())
        
        modelContext.insert(affirmation)
        try? modelContext.save()
        
        return affirmation
    }
    
    func toggleAffirmationLike() {
        guard let affirmation = todayAffirmation else { return }
        affirmation.liked.toggle()
        try? modelContext.save()
        HapticManager.shared.impact(style: .light)
    }
}
```

### Example: JournalViewModel

```swift
import SwiftUI
import SwiftData

@Observable
final class JournalViewModel {
    var entries: [JournalEntry] = []
    var isLoading = false
    var searchQuery = ""
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var filteredEntries: [JournalEntry] {
        if searchQuery.isEmpty {
            return entries
        }
        return entries.filter { entry in
            entry.title.localizedCaseInsensitiveContains(searchQuery) ||
            entry.content.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    @MainActor
    func loadEntries() async {
        isLoading = true
        defer { isLoading = false }
        
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func createEntry(title: String, content: String, moodEmoji: String, tags: [String], highlights: [String]) {
        let entry = JournalEntry(title: title, content: content, moodEmoji: moodEmoji)
        entry.tags = tags
        entry.highlights = highlights
        
        modelContext.insert(entry)
        try? modelContext.save()
        
        Task { await loadEntries() }
        HapticManager.shared.notification(type: .success)
    }
    
    func updateEntry(_ entry: JournalEntry, title: String, content: String, tags: [String], highlights: [String]) {
        entry.title = title
        entry.content = content
        entry.tags = tags
        entry.highlights = highlights
        entry.modifiedAt = Date()
        
        try? modelContext.save()
        Task { await loadEntries() }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        Task { await loadEntries() }
    }
}
```

---

## App Entry Point

```swift
// ShiftMoodApp.swift
import SwiftUI
import SwiftData

@main
struct ShiftMoodApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Shift.self,
            Mood.self,
            JournalEntry.self,
            Vacation.self,
            DailyAffirmation.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            if onboardingCompleted {
                ContentView()
                    .modelContainer(sharedModelContainer)
            } else {
                OnboardingView(onComplete: {
                    onboardingCompleted = true
                })
                .modelContainer(sharedModelContainer)
            }
        }
    }
}

// ContentView.swift (TabView container)
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
            
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(1)
            
            StatsPlaceholderView()
                .tabItem {
                    Label("Statistiques", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color(hex: "F59E0B")) // Primary color
    }
}
```

---

## Reusable Components

### MoodSlider

```swift
import SwiftUI

struct MoodSlider: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let labels: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(labels[value - 1])
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                ForEach(range, id: \.self) { level in
                    Circle()
                        .fill(value >= level ? color : Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("\(level)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(value >= level ? .white : .secondary)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                value = level
                            }
                            HapticManager.shared.impact(style: .light)
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Usage
MoodSlider(
    title: "Niveau d'énergie",
    icon: "bolt.fill",
    value: $energy,
    range: 1...5,
    labels: ["Épuisé", "Faible", "Moyen", "Bon", "Excellent"],
    color: Color(hex: "F59E0B")
)
```

### EmojiMoodSelector

```swift
import SwiftUI

struct EmojiMoodSelector: View {
    @Binding var selectedBadges: [String]
    let badges = MoodBadge.allCases
    let multiSelect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comment te sens-tu ?")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(badges, id: \.self) { badge in
                    let isSelected = selectedBadges.contains(badge.rawValue)
                    
                    VStack(spacing: 4) {
                        Text(badge.rawValue)
                            .font(.system(size: 32))
                        Text(badge.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color(hex: "F59E0B").opacity(0.1) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        toggleBadge(badge.rawValue)
                    }
                }
            }
        }
    }
    
    private func toggleBadge(_ badge: String) {
        if multiSelect {
            if let index = selectedBadges.firstIndex(of: badge) {
                selectedBadges.remove(at: index)
            } else {
                selectedBadges.append(badge)
            }
        } else {
            selectedBadges = [badge]
        }
        HapticManager.shared.impact(style: .light)
    }
}
```

### TagChipView

```swift
import SwiftUI

struct TagChipView: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    let onRemove: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
            
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isSelected ? Color(hex: "F59E0B") : Color(.systemGray5))
        )
        .foregroundStyle(isSelected ? .white : .primary)
        .onTapGesture(perform: onTap)
    }
}

// Suggested tags view
struct TagSelectorView: View {
    @Binding var selectedTags: [String]
    @State private var customTag = ""
    
    let suggestedTags = [
        "Shift difficile", "Belle rencontre", "Apprentissage",
        "Équipe géniale", "Fatigue", "Fierté", "Questionnement",
        "Urgence", "Décès", "Rétablissement", "Famille"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.subheadline)
                .fontWeight(.medium)
            
            FlowLayout(spacing: 8) {
                ForEach(suggestedTags, id: \.self) { tag in
                    TagChipView(
                        tag: tag,
                        isSelected: selectedTags.contains(tag),
                        onTap: { toggleTag(tag) },
                        onRemove: nil
                    )
                }
                
                ForEach(selectedTags.filter { !suggestedTags.contains($0) }, id: \.self) { tag in
                    TagChipView(
                        tag: tag,
                        isSelected: true,
                        onTap: {},
                        onRemove: { removeTag(tag) }
                    )
                }
            }
            
            HStack {
                TextField("Ajouter un tag personnalisé", text: $customTag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addCustomTag()
                    }
                
                Button("Ajouter") {
                    addCustomTag()
                }
                .buttonStyle(.borderedProminent)
                .disabled(customTag.isEmpty)
            }
        }
    }
    
    private func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func removeTag(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
    }
    
    private func addCustomTag() {
        let trimmed = customTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !selectedTags.contains(trimmed) {
            selectedTags.append(trimmed)
            customTag = ""
        }
    }
}

// FlowLayout helper (iOS 16+)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX - spacing)
            }
            
            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}
```

---

## Utilities

### HapticManager

```swift
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
```

### Color Extensions

```swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### Date Extensions

```swift
import Foundation

extension Date {
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: self)
    }
    
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let week = components.weekOfYear, week >= 1 {
            return "Il y a \(week) semaine\(week > 1 ? "s" : "")"
        } else if let day = components.day, day >= 1 {
            return "Il y a \(day) jour\(day > 1 ? "s" : "")"
        } else if let hour = components.hour, hour >= 1 {
            return "Il y a \(hour) heure\(hour > 1 ? "s" : "")"
        } else if let minute = components.minute, minute >= 1 {
            return "Il y a \(minute) minute\(minute > 1 ? "s" : "")"
        } else {
            return "À l'instant"
        }
    }
}
```

### VacationCalculator

```swift
import Foundation

struct VacationCalculator {
    static func workingDaysUntil(_ date: Date, from: Date = Date()) -> Int {
        let calendar = Calendar.current
        var workingDays = 0
        var currentDate = calendar.startOfDay(for: from)
        let targetDate = calendar.startOfDay(for: date)
        
        while currentDate < targetDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            // 1 = Sunday, 7 = Saturday
            if weekday != 1 && weekday != 7 {
                workingDays += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return workingDays
    }
}
```

---

## Preview Data

```swift
import Foundation
import SwiftData

extension UserProfile {
    static var preview: UserProfile {
        UserProfile(firstName: "Steve")
    }
}

extension JournalEntry {
    static var preview: JournalEntry {
        let entry = JournalEntry(
            title: "Shift de nuit difficile",
            content: "Beaucoup de patients cette nuit, peu de sommeil. Mais j'ai réussi à stabiliser Mr. Dupont, c'est une victoire.",
            moodEmoji: "😴"
        )
        entry.tags = ["Nuit", "Fatigue", "Fierté"]
        entry.highlights = [
            "Stabilisation réussie d'un patient critique",
            "Bonne collaboration avec l'équipe",
            "Besoin de mieux gérer ma récupération"
        ]
        return entry
    }
}

extension Vacation {
    static var preview: Vacation {
        let startDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        let endDate = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
        return Vacation(startDate: startDate, endDate: endDate)
    }
}

extension DailyAffirmation {
    static var preview: DailyAffirmation {
        DailyAffirmation(
            text: "Je fais une différence, même dans les petits gestes",
            category: .resilience
        )
    }
}
```

---

## Constants

```swift
import Foundation

enum AppConstants {
    static let appName = "ShiftMood"
    static let version = "0.1"
    static let build = "1"
    static let supportEmail = "steve@steverover.com"
    
    enum Storage {
        static let onboardingCompleted = "onboardingCompleted"
        static let userName = "userName"
    }
    
    enum Limits {
        static let maxHighlights = 3
        static let maxTags = 10
        static let journalTitleMaxLength = 100
        static let journalContentMaxLength = 5000
    }
    
    enum Animation {
        static let springResponse = 0.3
        static let springDamping = 0.7
    }
}
```

---

## Error Handling

```swift
enum ShiftMoodError: LocalizedError {
    case dataNotFound
    case saveFailed
    case invalidInput
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "Les données demandées n'ont pas été trouvées."
        case .saveFailed:
            return "Impossible de sauvegarder les données."
        case .invalidInput:
            return "Les données saisies ne sont pas valides."
        case .unknown:
            return "Une erreur inconnue s'est produite."
        }
    }
}
```

---

## Testing Strategy

### Unit Tests
- ViewModels logic (mood calculations, vacation countdown)
- Data transformations
- Date utilities
- Validation functions

### UI Tests
- Onboarding flow
- Journal entry creation
- Check-in/check-out flows
- Navigation between tabs

### Manual TestFlight Tests
- Real-world usage over 7 days
- Feedback on affirmations relevance
- UI/UX pain points
- Performance on older devices (iPhone 12+)

---

**Last Updated:** January 29, 2026
