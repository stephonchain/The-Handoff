import SwiftData
import Foundation
import SwiftUI

// MARK: - User Profile

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

// MARK: - Shift

@Model
final class Shift {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: ShiftType
    var startTime: Date?
    var endTime: Date?

    @Relationship(deleteRule: .cascade) var preMood: Mood?
    @Relationship(deleteRule: .cascade) var postMood: Mood?

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

    var hasPreMood: Bool { preMood != nil }
    var hasPostMood: Bool { postMood != nil }
}

// MARK: - Mood

@Model
final class Mood {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var energy: Int
    var stress: Int
    var motivation: Int
    var emotionalLoad: Int?
    var fatigue: Int?
    var satisfaction: Int?
    var badges: [String]
    var notes: String?
    var isPreShift: Bool

    init(energy: Int, stress: Int, motivation: Int, isPreShift: Bool = true) {
        self.id = UUID()
        self.timestamp = Date()
        self.energy = energy
        self.stress = stress
        self.motivation = motivation
        self.isPreShift = isPreShift
        self.badges = []
    }

    init(fatigue: Int, emotionalLoad: Int, satisfaction: Int, badges: [String] = []) {
        self.id = UUID()
        self.timestamp = Date()
        self.energy = 0
        self.stress = 0
        self.motivation = 0
        self.fatigue = fatigue
        self.emotionalLoad = emotionalLoad
        self.satisfaction = satisfaction
        self.badges = badges
        self.isPreShift = false
    }

    var averagePreShiftScore: Double {
        guard isPreShift else { return 0 }
        return Double(energy + (6 - stress) + motivation) / 3.0
    }

    var averagePostShiftScore: Double {
        guard !isPreShift,
              let f = fatigue,
              let e = emotionalLoad,
              let s = satisfaction else { return 0 }
        return Double((6 - f) + (6 - e) + s) / 3.0
    }
}

// MARK: - Journal Entry

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

    var preview: String {
        let maxLength = 100
        if content.count <= maxLength { return content }
        let index = content.index(content.startIndex, offsetBy: maxLength)
        return String(content[..<index]) + "..."
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    var isToday: Bool { Calendar.current.isDateInToday(createdAt) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(createdAt) }
}

// MARK: - Vacation

@Model
final class Vacation {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var type: VacationType
    var status: VacationStatus
    var customName: String?

    init(startDate: Date, endDate: Date, type: VacationType = .vacation, status: VacationStatus = .planned) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.status = status
    }

    var daysCount: Int {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    var isPast: Bool { endDate < Date() }
    var isUpcoming: Bool { startDate > Date() }
    var isCurrent: Bool { startDate <= Date() && Date() <= endDate }

    var displayName: String { customName ?? type.rawValue }

    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Daily Affirmation

@Model
final class DailyAffirmation {
    @Attribute(.unique) var id: UUID
    var text: String
    var category: AffirmationCategory
    var shownDate: Date?
    var liked: Bool
    var sourceIndex: Int?

    init(text: String, category: AffirmationCategory, sourceIndex: Int? = nil) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.liked = false
        self.sourceIndex = sourceIndex
    }
}

// MARK: - Enums

enum ShiftType: String, Codable, CaseIterable {
    case jour = "Day"
    case nuit = "Night"
    case repos = "Rest"

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

enum VacationType: String, Codable, CaseIterable {
    case vacation = "Vacation"
    case compTime = "Comp Time"
    case training = "Training"

    var icon: String {
        switch self {
        case .vacation: return "sun.max.fill"
        case .compTime: return "calendar.badge.clock"
        case .training: return "graduationcap.fill"
        }
    }
}

enum VacationStatus: String, Codable, CaseIterable {
    case planned = "Planned"
    case approved = "Approved"
    case ongoing = "Ongoing"
    case completed = "Completed"

    var color: Color {
        switch self {
        case .planned: return .orange
        case .approved: return .green
        case .ongoing: return .blue
        case .completed: return .gray
        }
    }
}

enum AffirmationCategory: String, Codable, CaseIterable {
    case resilience = "Resilience"
    case competence = "Competence"
    case compassion = "Compassion"
    case balance = "Balance"

    var color: Color {
        switch self {
        case .resilience: return Color(hex: "F59E0B")
        case .competence: return Color(hex: "8B5CF6")
        case .compassion: return Color(hex: "10B981")
        case .balance: return Color(hex: "3B82F6")
        }
    }

    var icon: String {
        switch self {
        case .resilience: return "shield.fill"
        case .competence: return "star.fill"
        case .compassion: return "heart.fill"
        case .balance: return "scale.3d"
        }
    }
}

enum MoodBadge: String, CaseIterable {
    case happy = "😊"
    case sad = "😔"
    case calm = "😌"
    case anxious = "😰"
    case proud = "💪"
    case tired = "😴"
    case frustrated = "😤"
    case grateful = "🙏"

    var labelKey: String {
        switch self {
        case .happy: return "badge_happy"
        case .sad: return "badge_sad"
        case .calm: return "badge_calm"
        case .anxious: return "badge_anxious"
        case .proud: return "badge_proud"
        case .tired: return "badge_tired"
        case .frustrated: return "badge_frustrated"
        case .grateful: return "badge_grateful"
        }
    }
}

// MARK: - Affirmations Library

struct AffirmationData {
    let text: String
    let category: AffirmationCategory
}

struct AffirmationsLibrary {
    static let allAffirmations: [AffirmationData] = [
        // Resilience (10)
        AffirmationData(text: "I make a difference, even in small gestures", category: .resilience),
        AffirmationData(text: "My limits protect my ability to care", category: .resilience),
        AffirmationData(text: "Each difficult shift makes me stronger", category: .resilience),
        AffirmationData(text: "I deserve rest as much as my patients", category: .resilience),
        AffirmationData(text: "My fatigue is legitimate, not a weakness", category: .resilience),
        AffirmationData(text: "I can't control everything, and that's okay", category: .resilience),
        AffirmationData(text: "Asking for help is a sign of wisdom", category: .resilience),
        AffirmationData(text: "I'm human, not a machine", category: .resilience),
        AffirmationData(text: "My emotions are valid, even at work", category: .resilience),
        AffirmationData(text: "I choose to preserve myself to last", category: .resilience),

        // Competence (10)
        AffirmationData(text: "My experience is valuable", category: .competence),
        AffirmationData(text: "I know what I'm doing, I was trained for this", category: .competence),
        AffirmationData(text: "Every technical gesture I perform matters", category: .competence),
        AffirmationData(text: "I learn from every situation", category: .competence),
        AffirmationData(text: "My vigilance saves lives", category: .competence),
        AffirmationData(text: "I'm capable of handling the unexpected", category: .competence),
        AffirmationData(text: "My knowledge strengthens every day", category: .competence),
        AffirmationData(text: "I trust my clinical judgment", category: .competence),
        AffirmationData(text: "My professionalism makes a difference", category: .competence),
        AffirmationData(text: "I'm proud of my profession", category: .competence),

        // Compassion (15)
        AffirmationData(text: "My empathy is my strength, not my weakness", category: .compassion),
        AffirmationData(text: "Listening to a patient is care in itself", category: .compassion),
        AffirmationData(text: "A smile can change someone's day", category: .compassion),
        AffirmationData(text: "I see the person behind the condition", category: .compassion),
        AffirmationData(text: "My presence brings comfort", category: .compassion),
        AffirmationData(text: "Every patient deserves my kindness", category: .compassion),
        AffirmationData(text: "I'm the human connection in a technical system", category: .compassion),
        AffirmationData(text: "My humanity is my best tool", category: .compassion),
        AffirmationData(text: "Care begins with a look", category: .compassion),
        AffirmationData(text: "I create safety through my presence", category: .compassion),
        AffirmationData(text: "My attention is a gift I offer", category: .compassion),
        AffirmationData(text: "Being there matters", category: .compassion),
        AffirmationData(text: "My compassion doesn't run out, it grows", category: .compassion),
        AffirmationData(text: "Every gentle gesture is an act of resistance", category: .compassion),
        AffirmationData(text: "I care with both my hands and my heart", category: .compassion),

        // Balance (15)
        AffirmationData(text: "My days off are sacred", category: .balance),
        AffirmationData(text: "I'm more than my job", category: .balance),
        AffirmationData(text: "Taking care of myself allows me to care for others", category: .balance),
        AffirmationData(text: "Saying no protects my energy", category: .balance),
        AffirmationData(text: "My personal wellbeing isn't selfish", category: .balance),
        AffirmationData(text: "I deserve a life outside the hospital", category: .balance),
        AffirmationData(text: "My hobbies recharge me to care better", category: .balance),
        AffirmationData(text: "Work-life balance is a right, not a luxury", category: .balance),
        AffirmationData(text: "I don't bring work home (in my head)", category: .balance),
        AffirmationData(text: "My loved ones need me whole, not exhausted", category: .balance),
        AffirmationData(text: "Disconnecting is necessary to reconnect", category: .balance),
        AffirmationData(text: "My identity extends beyond my scrubs", category: .balance),
        AffirmationData(text: "I cultivate my personal life with as much care", category: .balance),
        AffirmationData(text: "My time off is vital, not optional", category: .balance),
        AffirmationData(text: "I choose to live, not just survive", category: .balance)
    ]

    static func getAffirmationForDay(_ date: Date = Date()) -> AffirmationData {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % allAffirmations.count
        return allAffirmations[index]
    }
}

// MARK: - Preview Data

#if DEBUG
extension UserProfile {
    static var preview: UserProfile {
        let profile = UserProfile(firstName: "Steve")
        profile.onboardingCompleted = true
        return profile
    }
}

extension Shift {
    static var preview: Shift {
        let shift = Shift(date: Date(), type: .jour)
        shift.startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
        shift.endTime = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())
        return shift
    }
}

extension JournalEntry {
    static var preview: JournalEntry {
        let entry = JournalEntry(
            title: "Difficult night shift",
            content: "So many patients tonight, little sleep. But I managed to stabilize Mr. Johnson, that's a win.",
            moodEmoji: "😴"
        )
        entry.tags = ["Night", "Fatigue", "Pride"]
        entry.highlights = [
            "Successfully stabilized a critical patient",
            "Great collaboration with the team",
            "Need to better manage my recovery"
        ]
        return entry
    }
}

extension Vacation {
    static var preview: Vacation {
        let startDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        let endDate = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
        let vacation = Vacation(startDate: startDate, endDate: endDate, type: .vacation)
        vacation.customName = "Summer Break"
        return vacation
    }
}

extension DailyAffirmation {
    static var preview: DailyAffirmation {
        let affirmation = DailyAffirmation(
            text: "I make a difference, even in small gestures",
            category: .resilience
        )
        affirmation.shownDate = Date()
        return affirmation
    }
}
#endif
