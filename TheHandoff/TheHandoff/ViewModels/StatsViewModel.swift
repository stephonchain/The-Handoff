import SwiftUI
import SwiftData
import Foundation

@Observable
final class StatsViewModel {
    private let modelContext: ModelContext

    var shifts: [Shift] = []
    var journalEntries: [JournalEntry] = []

    // Computed stats
    var stabilityStreak: Int = 0
    var longestStreak: Int = 0
    var totalCheckIns: Int = 0
    var totalCheckOuts: Int = 0
    var averagePreMood: Double = 0
    var averagePostMood: Double = 0
    var moodImprovement: Double = 0
    var earnedBadges: [AchievementBadge] = []
    var insights: [Insight] = []
    var weeklyMoodData: [MoodDataPoint] = []
    var moodComparisonData: [MoodComparison] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @MainActor
    func loadData() async {
        // Fetch shifts
        let shiftDescriptor = FetchDescriptor<Shift>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        shifts = (try? modelContext.fetch(shiftDescriptor)) ?? []

        // Fetch journal entries
        let journalDescriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        journalEntries = (try? modelContext.fetch(journalDescriptor)) ?? []

        computeStats()
        computeBadges()
        generateInsights()
        computeChartData()
    }

    // MARK: - Stats Computation

    private func computeStats() {
        // Count check-ins and check-outs
        totalCheckIns = shifts.filter { $0.hasPreMood }.count
        totalCheckOuts = shifts.filter { $0.hasPostMood }.count

        // Compute stability streak (consecutive days with at least one check-in)
        stabilityStreak = computeCurrentStreak()
        longestStreak = computeLongestStreak()

        // Average moods
        let preMoods = shifts.compactMap { $0.preMood }
        let postMoods = shifts.compactMap { $0.postMood }

        if !preMoods.isEmpty {
            averagePreMood = preMoods.reduce(0.0) { $0 + $1.averagePreShiftScore } / Double(preMoods.count)
        }

        if !postMoods.isEmpty {
            averagePostMood = postMoods.reduce(0.0) { $0 + $1.averagePostShiftScore } / Double(postMoods.count)
        }

        // Mood improvement (positive = feeling better after shift)
        if averagePreMood > 0 && averagePostMood > 0 {
            moodImprovement = ((averagePostMood - averagePreMood) / averagePreMood) * 100
        }
    }

    private func computeCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // Check today first
        let todayShifts = shifts.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
        let hasTodayCheckIn = todayShifts.contains { $0.hasPreMood || $0.hasPostMood }

        if !hasTodayCheckIn {
            // Check if yesterday had a check-in (grace period)
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        while true {
            let dayShifts = shifts.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
            let hasCheckIn = dayShifts.contains { $0.hasPreMood || $0.hasPostMood }

            if hasCheckIn {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        return streak
    }

    private func computeLongestStreak() -> Int {
        let calendar = Calendar.current
        var maxStreak = 0
        var currentStreak = 0

        // Get unique dates with check-ins, sorted
        let datesWithCheckIn = Set(shifts.filter { $0.hasPreMood || $0.hasPostMood }
            .map { calendar.startOfDay(for: $0.date) })
            .sorted(by: >)

        guard !datesWithCheckIn.isEmpty else { return 0 }

        var previousDate: Date?

        for date in datesWithCheckIn {
            if let prev = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: date, to: prev).day ?? 0
                if daysDiff == 1 {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            previousDate = date
        }

        return max(maxStreak, currentStreak)
    }

    // MARK: - Badges

    private func computeBadges() {
        earnedBadges = []

        // First Steps - First check-in
        if totalCheckIns >= 1 {
            earnedBadges.append(.firstCheckIn)
        }

        // Regular - 10 check-ins
        if totalCheckIns >= 10 {
            earnedBadges.append(.tenCheckIns)
        }

        // Dedicated - 50 check-ins
        if totalCheckIns >= 50 {
            earnedBadges.append(.fiftyCheckIns)
        }

        // Week Warrior - 7 day streak
        if longestStreak >= 7 {
            earnedBadges.append(.weekStreak)
        }

        // Month Master - 30 day streak
        if longestStreak >= 30 {
            earnedBadges.append(.monthStreak)
        }

        // Balanced - 7 days without low mood
        if hasSevenDaysWithoutLowMood() {
            earnedBadges.append(.balancedWeek)
        }

        // Reflective - 5 journal entries
        if journalEntries.count >= 5 {
            earnedBadges.append(.fiveJournals)
        }

        // Storyteller - 20 journal entries
        if journalEntries.count >= 20 {
            earnedBadges.append(.twentyJournals)
        }

        // Pride Collector - 5 entries with highlights
        let entriesWithHighlights = journalEntries.filter { !$0.highlights.isEmpty }.count
        if entriesWithHighlights >= 5 {
            earnedBadges.append(.prideCollector)
        }

        // Full Circle - Complete check-in AND check-out same day 10 times
        let completeDays = shifts.filter { $0.hasPreMood && $0.hasPostMood }.count
        if completeDays >= 10 {
            earnedBadges.append(.fullCircle)
        }
    }

    private func hasSevenDaysWithoutLowMood() -> Bool {
        let calendar = Calendar.current
        let lastSevenDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }

        for day in lastSevenDays {
            let dayShifts = shifts.filter { calendar.isDate($0.date, inSameDayAs: day) }
            for shift in dayShifts {
                if let pre = shift.preMood, pre.averagePreShiftScore < 2.0 {
                    return false
                }
                if let post = shift.postMood, post.averagePostShiftScore < 2.0 {
                    return false
                }
            }
        }

        return totalCheckIns >= 7 // Need at least 7 check-ins to earn this
    }

    // MARK: - Insights

    private func generateInsights() {
        insights = []

        guard shifts.count >= 5 else {
            insights.append(Insight(
                icon: "chart.line.uptrend.xyaxis",
                title: String(localized: "insight_need_more_data_title"),
                description: String(localized: "insight_need_more_data_desc"),
                type: .neutral
            ))
            return
        }

        // Insight: Mood improvement after shift
        if moodImprovement > 10 {
            insights.append(Insight(
                icon: "arrow.up.circle.fill",
                title: String(localized: "insight_mood_improves_title"),
                description: String(format: String(localized: "insight_mood_improves_desc"), Int(moodImprovement)),
                type: .positive
            ))
        } else if moodImprovement < -10 {
            insights.append(Insight(
                icon: "arrow.down.circle.fill",
                title: String(localized: "insight_mood_drops_title"),
                description: String(format: String(localized: "insight_mood_drops_desc"), Int(abs(moodImprovement))),
                type: .warning
            ))
        }

        // Insight: Stability streak
        if stabilityStreak >= 3 {
            insights.append(Insight(
                icon: "flame.fill",
                title: String(localized: "insight_stability_title"),
                description: String(format: String(localized: "insight_stability_desc"), stabilityStreak),
                type: .positive
            ))
        }

        // Insight: High stress pattern
        let highStressShifts = shifts.filter { ($0.preMood?.stress ?? 0) >= 4 }
        if highStressShifts.count > shifts.count / 3 && shifts.count >= 5 {
            insights.append(Insight(
                icon: "exclamationmark.triangle.fill",
                title: String(localized: "insight_high_stress_title"),
                description: String(localized: "insight_high_stress_desc"),
                type: .warning
            ))
        }

        // Insight: Journal correlation
        let shiftsWithJournal = shifts.filter { !($0.journalEntries?.isEmpty ?? true) }
        if shiftsWithJournal.count >= 3 {
            let avgMoodWithJournal = shiftsWithJournal.compactMap { $0.postMood?.averagePostShiftScore }.reduce(0, +) / Double(shiftsWithJournal.count)
            let shiftsWithoutJournal = shifts.filter { $0.journalEntries?.isEmpty ?? true }
            if !shiftsWithoutJournal.isEmpty {
                let avgMoodWithoutJournal = shiftsWithoutJournal.compactMap { $0.postMood?.averagePostShiftScore }.reduce(0, +) / Double(shiftsWithoutJournal.count)

                if avgMoodWithJournal > avgMoodWithoutJournal + 0.5 {
                    insights.append(Insight(
                        icon: "book.fill",
                        title: String(localized: "insight_journal_helps_title"),
                        description: String(localized: "insight_journal_helps_desc"),
                        type: .positive
                    ))
                }
            }
        }

        // Insight: Energy pattern
        let lowEnergyShifts = shifts.filter { ($0.preMood?.energy ?? 3) <= 2 }
        if lowEnergyShifts.count > shifts.count / 2 && shifts.count >= 5 {
            insights.append(Insight(
                icon: "battery.25",
                title: String(localized: "insight_low_energy_title"),
                description: String(localized: "insight_low_energy_desc"),
                type: .warning
            ))
        }
    }

    // MARK: - Chart Data

    private func computeChartData() {
        computeWeeklyMoodData()
        computeMoodComparison()
    }

    private func computeWeeklyMoodData() {
        let calendar = Calendar.current
        weeklyMoodData = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayShifts = shifts.filter { calendar.isDate($0.date, inSameDayAs: date) }

            let preMoods = dayShifts.compactMap { $0.preMood?.averagePreShiftScore }
            let postMoods = dayShifts.compactMap { $0.postMood?.averagePostShiftScore }

            let avgPre = preMoods.isEmpty ? nil : preMoods.reduce(0, +) / Double(preMoods.count)
            let avgPost = postMoods.isEmpty ? nil : postMoods.reduce(0, +) / Double(postMoods.count)

            weeklyMoodData.append(MoodDataPoint(
                date: date,
                preShiftMood: avgPre,
                postShiftMood: avgPost
            ))
        }
    }

    private func computeMoodComparison() {
        moodComparisonData = []

        // Get last 10 complete shifts (both pre and post mood)
        let completeShifts = shifts
            .filter { $0.hasPreMood && $0.hasPostMood }
            .prefix(10)

        for shift in completeShifts {
            guard let pre = shift.preMood, let post = shift.postMood else { continue }
            moodComparisonData.append(MoodComparison(
                date: shift.date,
                preMood: pre.averagePreShiftScore,
                postMood: post.averagePostShiftScore
            ))
        }

        moodComparisonData.reverse() // Chronological order
    }
}

// MARK: - Supporting Types

struct MoodDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let preShiftMood: Double?
    let postShiftMood: Double?

    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct MoodComparison: Identifiable {
    let id = UUID()
    let date: Date
    let preMood: Double
    let postMood: Double

    var improvement: Double { postMood - preMood }
    var improved: Bool { improvement > 0 }

    var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct Insight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let type: InsightType
}

enum InsightType {
    case positive, warning, neutral

    var color: Color {
        switch self {
        case .positive: return Color(hex: "10B981")
        case .warning: return Color(hex: "F59E0B")
        case .neutral: return Color(hex: "6B7280")
        }
    }
}

enum AchievementBadge: String, CaseIterable, Identifiable {
    case firstCheckIn = "first_checkin"
    case tenCheckIns = "ten_checkins"
    case fiftyCheckIns = "fifty_checkins"
    case weekStreak = "week_streak"
    case monthStreak = "month_streak"
    case balancedWeek = "balanced_week"
    case fiveJournals = "five_journals"
    case twentyJournals = "twenty_journals"
    case prideCollector = "pride_collector"
    case fullCircle = "full_circle"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .firstCheckIn: return "star.fill"
        case .tenCheckIns: return "10.circle.fill"
        case .fiftyCheckIns: return "50.circle.fill"
        case .weekStreak: return "flame.fill"
        case .monthStreak: return "crown.fill"
        case .balancedWeek: return "scale.3d"
        case .fiveJournals: return "book.fill"
        case .twentyJournals: return "books.vertical.fill"
        case .prideCollector: return "trophy.fill"
        case .fullCircle: return "arrow.triangle.2.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .firstCheckIn: return Color(hex: "F59E0B")
        case .tenCheckIns: return Color(hex: "8B5CF6")
        case .fiftyCheckIns: return Color(hex: "EC4899")
        case .weekStreak: return Color(hex: "EF4444")
        case .monthStreak: return Color(hex: "F59E0B")
        case .balancedWeek: return Color(hex: "10B981")
        case .fiveJournals: return Color(hex: "3B82F6")
        case .twentyJournals: return Color(hex: "6366F1")
        case .prideCollector: return Color(hex: "F59E0B")
        case .fullCircle: return Color(hex: "14B8A6")
        }
    }

    var titleKey: String { "badge_\(rawValue)_title" }
    var descriptionKey: String { "badge_\(rawValue)_desc" }
}
