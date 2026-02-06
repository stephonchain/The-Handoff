import SwiftUI
import SwiftData
import Charts

struct ProgressionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StatsViewModel?
    @State private var selectedTimeRange: TimeRange = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                if let vm = viewModel {
                    VStack(spacing: 20) {
                        stabilityCard(vm)
                        quickStatsGrid(vm)
                        moodTrendChart(vm)
                        moodComparisonSection(vm)
                        badgesSection(vm)
                        insightsSection(vm)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progression")
        }
        .task {
            if viewModel == nil {
                viewModel = StatsViewModel(modelContext: modelContext)
            }
            await viewModel?.loadData()
        }
    }

    // MARK: - Stability Card

    @ViewBuilder
    private func stabilityCard(_ vm: StatsViewModel) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Flame icon with streak
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)

                    VStack(spacing: 0) {
                        Text("\(vm.stabilityStreak)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("stats_stability_title")
                        .font(.headline)

                    if vm.stabilityStreak == 0 {
                        Text("stats_stability_start")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if vm.stabilityStreak == 1 {
                        Text("stats_stability_one_day")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(format: String(localized: "stats_stability_days"), vm.stabilityStreak))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if vm.longestStreak > vm.stabilityStreak {
                        Text(String(format: String(localized: "stats_record"), vm.longestStreak))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()
            }

            // Supportive message
            Text(stabilityMessage(streak: vm.stabilityStreak))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }

    private func stabilityMessage(streak: Int) -> String {
        if streak == 0 {
            return String(localized: "stats_msg_start")
        } else if streak < 3 {
            return String(localized: "stats_msg_beginning")
        } else if streak < 7 {
            return String(localized: "stats_msg_building")
        } else if streak < 14 {
            return String(localized: "stats_msg_strong")
        } else if streak < 30 {
            return String(localized: "stats_msg_impressive")
        } else {
            return String(localized: "stats_msg_master")
        }
    }

    // MARK: - Quick Stats Grid

    @ViewBuilder
    private func quickStatsGrid(_ vm: StatsViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                icon: "bolt.fill",
                value: "\(vm.totalCheckIns)",
                label: String(localized: "stats_total_checkins"),
                color: Color(hex: "F59E0B")
            )

            StatCard(
                icon: "moon.stars.fill",
                value: "\(vm.totalCheckOuts)",
                label: String(localized: "stats_total_checkouts"),
                color: Color(hex: "8B5CF6")
            )

            StatCard(
                icon: "face.smiling.fill",
                value: String(format: "%.1f", vm.averagePreMood),
                label: String(localized: "stats_avg_pre_mood"),
                color: Color(hex: "3B82F6")
            )

            StatCard(
                icon: "heart.fill",
                value: String(format: "%.1f", vm.averagePostMood),
                label: String(localized: "stats_avg_post_mood"),
                color: Color(hex: "10B981")
            )
        }
    }

    // MARK: - Mood Trend Chart

    @ViewBuilder
    private func moodTrendChart(_ vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("stats_mood_trend")
                .font(.headline)

            if vm.weeklyMoodData.isEmpty || vm.weeklyMoodData.allSatisfy({ $0.preShiftMood == nil && $0.postShiftMood == nil }) {
                emptyChartPlaceholder()
            } else {
                Chart {
                    ForEach(vm.weeklyMoodData) { point in
                        if let pre = point.preShiftMood {
                            LineMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Mood", pre)
                            )
                            .foregroundStyle(Color(hex: "F59E0B"))
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Mood", pre)
                            )
                            .foregroundStyle(Color(hex: "F59E0B"))
                        }

                        if let post = point.postShiftMood {
                            LineMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Mood", post)
                            )
                            .foregroundStyle(Color(hex: "8B5CF6"))
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Mood", post)
                            )
                            .foregroundStyle(Color(hex: "8B5CF6"))
                        }
                    }
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5])
                }
                .frame(height: 180)

                // Legend
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "F59E0B"))
                            .frame(width: 8, height: 8)
                        Text("stats_before_shift")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "8B5CF6"))
                            .frame(width: 8, height: 8)
                        Text("stats_after_shift")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }

    // MARK: - Mood Comparison (Before vs After)

    @ViewBuilder
    private func moodComparisonSection(_ vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("stats_before_after")
                .font(.headline)

            if vm.moodComparisonData.isEmpty {
                emptyChartPlaceholder()
            } else {
                Chart(vm.moodComparisonData) { comparison in
                    BarMark(
                        x: .value("Mood", comparison.preMood),
                        y: .value("Date", comparison.date, unit: .day)
                    )
                    .foregroundStyle(Color(hex: "F59E0B"))
                    .cornerRadius(4)

                    BarMark(
                        x: .value("Mood", comparison.postMood),
                        y: .value("Date", comparison.date, unit: .day)
                    )
                    .foregroundStyle(Color(hex: "8B5CF6"))
                    .cornerRadius(4)
                }
                .chartXScale(domain: 0...5)
                .chartYAxis {
                    AxisMarks { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.day().month(.abbreviated))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: CGFloat(vm.moodComparisonData.count * 50 + 20))

                // Summary
                if let avgImprovement = averageImprovement(vm.moodComparisonData) {
                    HStack {
                        Image(systemName: avgImprovement >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundStyle(avgImprovement >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444"))
                        Text(String(format: String(localized: avgImprovement >= 0 ? "stats_avg_improvement" : "stats_avg_decline"), abs(avgImprovement)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }

    private func averageImprovement(_ data: [MoodComparison]) -> Double? {
        guard !data.isEmpty else { return nil }
        let total = data.reduce(0.0) { $0 + $1.improvement }
        return (total / Double(data.count)) * 20 // Convert to percentage-like
    }

    // MARK: - Badges Section

    @ViewBuilder
    private func badgesSection(_ vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("stats_badges")
                    .font(.headline)
                Spacer()
                Text("\(vm.earnedBadges.count)/\(AchievementBadge.allCases.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach(AchievementBadge.allCases) { badge in
                    let isEarned = vm.earnedBadges.contains(badge)
                    BadgeView(badge: badge, isEarned: isEarned)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }

    // MARK: - Insights Section

    @ViewBuilder
    private func insightsSection(_ vm: StatsViewModel) -> some View {
        if !vm.insights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("stats_insights")
                    .font(.headline)

                ForEach(vm.insights) { insight in
                    InsightRow(insight: insight)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyChartPlaceholder() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title)
                .foregroundStyle(.tertiary)
            Text("stats_no_data")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }

            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .cardShadow()
    }
}

struct BadgeView: View {
    let badge: AchievementBadge
    let isEarned: Bool
    @State private var showingDetail = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isEarned ? badge.color.opacity(0.15) : Color(.systemGray5))
                    .frame(width: 56, height: 56)

                Image(systemName: badge.icon)
                    .font(.title2)
                    .foregroundStyle(isEarned ? badge.color : Color(.systemGray3))
            }

            Text(LocalizedStringKey(badge.titleKey))
                .font(.caption2)
                .foregroundStyle(isEarned ? .primary : .tertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .opacity(isEarned ? 1 : 0.5)
        .onTapGesture {
            if isEarned {
                showingDetail = true
                HapticManager.shared.impact(style: .light)
            }
        }
        .sheet(isPresented: $showingDetail) {
            BadgeDetailSheet(badge: badge)
                .presentationDetents([.medium])
        }
    }
}

struct BadgeDetailSheet: View {
    let badge: AchievementBadge
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [badge.color, badge.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: badge.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text(LocalizedStringKey(badge.titleKey))
                    .font(.title2)
                    .fontWeight(.bold)

                Text(LocalizedStringKey(badge.descriptionKey))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("button_close")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(badge.color)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
    }
}

struct InsightRow: View {
    let insight: Insight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundStyle(insight.type.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(insight.type.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Time Range

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case all = "All"
}
