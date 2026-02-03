import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    @State private var showingCheckIn = false
    @State private var showingCheckOut = false
    @State private var showingNewJournal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    affirmationCard
                    vacationCountdownCard
                    quickActionsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
        }
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(modelContext: modelContext)
            }
            await viewModel?.loadData()
        }
        .sheet(isPresented: $showingCheckIn) {
            CheckInView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingCheckOut) {
            CheckOutView(onJournalRequest: {
                showingCheckOut = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingNewJournal = true
                }
            })
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingNewJournal) {
            NewJournalView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let name = viewModel?.userProfile?.firstName {
                    Text("Hello, \(name) 👋")
                        .font(.title2)
                        .fontWeight(.bold)
                } else {
                    Text("Hello 👋")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Affirmation Card

    @ViewBuilder
    private var affirmationCard: some View {
        if let affirmation = viewModel?.todayAffirmation {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: affirmation.category.icon)
                        .font(.title3)
                    Spacer()
                    Button(action: { viewModel?.toggleAffirmationLike() }) {
                        Image(systemName: affirmation.liked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(affirmation.liked ? .red : .white.opacity(0.8))
                    }
                }

                Text(affirmation.text)
                    .font(.body)
                    .fontWeight(.medium)

                Text(affirmation.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [affirmation.category.color, affirmation.category.color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
    }

    // MARK: - Vacation Countdown

    @ViewBuilder
    private var vacationCountdownCard: some View {
        if let vacation = viewModel?.nextVacation, let days = viewModel?.daysUntilVacation, days > 0 {
            VStack(spacing: 8) {
                Text("🎉")
                    .font(.system(size: 36))

                Text("\(days)")
                    .font(.system(size: 48, weight: .heavy))
                    .contentTransition(.numericText(countsDown: true))

                Text("days until your time off!")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(vacation.dateRangeString)
                    .font(.caption)
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                LinearGradient(
                    colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home_quick_actions")
                .font(.headline)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "bolt.fill",
                    title: hasCheckedInToday ? String(localized: "checkout_title_short") : String(localized: "home_checkin_button"),
                    color: hasCheckedInToday ? Color(hex: "8B5CF6") : Color(hex: "F59E0B")
                ) {
                    if hasCheckedInToday {
                        showingCheckOut = true
                    } else {
                        showingCheckIn = true
                    }
                }

                QuickActionButton(
                    icon: "square.and.pencil",
                    title: String(localized: "home_journal_button"),
                    color: Color(hex: "10B981")
                ) {
                    showingNewJournal = true
                }
            }
        }
    }

    private var hasCheckedInToday: Bool {
        viewModel?.todayShift()?.hasPreMood ?? false
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .cardShadow()
        }
    }
}
