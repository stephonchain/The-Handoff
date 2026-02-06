import SwiftUI
import SwiftData

struct CheckInTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Shift.date, order: .reverse) private var shifts: [Shift]

    @State private var showingPreShift = false
    @State private var showingPostShift = false
    @State private var showingQuickMode = false

    private var todayShift: Shift? {
        shifts.first { Calendar.current.isDateInToday($0.date) }
    }

    private var hasCheckedInToday: Bool {
        todayShift?.hasPreMood ?? false
    }

    private var hasCheckedOutToday: Bool {
        todayShift?.hasPostMood ?? false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Quick mode button
                    quickModeButton

                    // Main actions
                    VStack(spacing: 16) {
                        checkInCard
                        checkOutCard
                    }

                    // Today's summary if exists
                    if hasCheckedInToday || hasCheckedOutToday {
                        todaySummary
                    }

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Check-in")
        }
        .sheet(isPresented: $showingPreShift) {
            PreShiftCheckInView()
        }
        .sheet(isPresented: $showingPostShift) {
            PostShiftCheckInView()
        }
        .sheet(isPresented: $showingQuickMode) {
            QuickCheckInView()
                .presentationDetents([.medium])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🩺")
                .font(.system(size: 48))

            Text("Ton rituel quotidien")
                .font(.title2)
                .fontWeight(.bold)

            Text("30 secondes pour prendre soin de toi")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
    }

    // MARK: - Quick Mode

    private var quickModeButton: some View {
        Button(action: { showingQuickMode = true }) {
            HStack {
                Image(systemName: "bolt.circle.fill")
                    .font(.title3)
                Text("Je suis rincé(e), version ultra courte")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(Color(hex: "8B5CF6"))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(hex: "8B5CF6").opacity(0.1))
            .clipShape(Capsule())
        }
    }

    // MARK: - Check-in Card

    private var checkInCard: some View {
        Button(action: { showingPreShift = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(hasCheckedInToday ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                        .frame(width: 56, height: 56)

                    Image(systemName: hasCheckedInToday ? "checkmark" : "sunrise.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Avant le shift")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(hasCheckedInToday ? "Complété ✓" : "Comment tu te sens ?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
        .disabled(hasCheckedInToday)
        .opacity(hasCheckedInToday ? 0.7 : 1)
    }

    // MARK: - Check-out Card

    private var checkOutCard: some View {
        Button(action: { showingPostShift = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(hasCheckedOutToday ? Color(hex: "10B981") : Color(hex: "8B5CF6"))
                        .frame(width: 56, height: 56)

                    Image(systemName: hasCheckedOutToday ? "checkmark" : "sunset.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Après le shift")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(hasCheckedOutToday ? "Complété ✓" : "Comment s'est passée ta journée ?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
        .disabled(!hasCheckedInToday || hasCheckedOutToday)
        .opacity((!hasCheckedInToday || hasCheckedOutToday) ? 0.7 : 1)
    }

    // MARK: - Today's Summary

    @ViewBuilder
    private var todaySummary: some View {
        if let shift = todayShift {
            VStack(alignment: .leading, spacing: 12) {
                Text("Aujourd'hui")
                    .font(.headline)

                if let pre = shift.preMood {
                    HStack {
                        Label("Avant", systemImage: "sunrise.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "F59E0B"))
                        Spacer()
                        moodSummary(energy: pre.energy, stress: pre.stress, motivation: pre.motivation)
                    }
                }

                if let post = shift.postMood {
                    HStack {
                        Label("Après", systemImage: "sunset.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "8B5CF6"))
                        Spacer()
                        postMoodSummary(post)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .cardShadow()
        }
    }

    private func moodSummary(energy: Int, stress: Int, motivation: Int) -> some View {
        HStack(spacing: 12) {
            Label("\(energy)", systemImage: "bolt.fill")
            Label("\(stress)", systemImage: "brain.head.profile")
            Label("\(motivation)", systemImage: "flame.fill")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func postMoodSummary(_ mood: Mood) -> some View {
        HStack(spacing: 12) {
            if let fatigue = mood.fatigue {
                Label("\(fatigue)", systemImage: "battery.25")
            }
            if let load = mood.emotionalLoad {
                Label("\(load)", systemImage: "heart.fill")
            }
            if let sat = mood.satisfaction {
                Label("\(sat)", systemImage: "star.fill")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
