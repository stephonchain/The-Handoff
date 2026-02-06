import SwiftUI
import SwiftData

struct CheckInTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Shift.date, order: .reverse) private var shifts: [Shift]

    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker = false
    @State private var showingPreShift = false
    @State private var showingPostShift = false
    @State private var showingQuickMode = false
    @State private var editingPreShift = false
    @State private var editingPostShift = false
    @State private var showingPaywall = false
    @State private var subscriptionManager = SubscriptionManager.shared

    private let freeWeeklyLimit = 3

    private var isPremium: Bool {
        subscriptionManager.isPremium
    }

    private var weeklyCheckInCount: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return shifts.filter { $0.date >= startOfWeek && $0.hasPreMood }.count
    }

    private var canDoCheckIn: Bool {
        isPremium || weeklyCheckInCount < freeWeeklyLimit
    }

    private var remainingFreeCheckIns: Int {
        max(0, freeWeeklyLimit - weeklyCheckInCount)
    }

    private var selectedShift: Shift? {
        shifts.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var hasCheckedIn: Bool {
        selectedShift?.hasPreMood ?? false
    }

    private var hasCheckedOut: Bool {
        selectedShift?.hasPostMood ?? false
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Date selector
                    dateSelector

                    // Header with icon
                    headerSection

                    // Quick mode (only for today)
                    if isToday {
                        quickModeButton
                    }

                    // Main actions
                    VStack(spacing: 12) {
                        checkInCard
                        checkOutCard
                    }

                    // Summary
                    if hasCheckedIn || hasCheckedOut {
                        summaryCard
                    }

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Check-in")
        }
        .sheet(isPresented: $showingPreShift) {
            PreShiftCheckInView(date: selectedDate)
        }
        .sheet(isPresented: $showingPostShift) {
            PostShiftCheckInView(date: selectedDate)
        }
        .sheet(isPresented: $editingPreShift) {
            if let shift = selectedShift, let mood = shift.preMood {
                EditPreShiftView(shift: shift, mood: mood)
            }
        }
        .sheet(isPresented: $editingPostShift) {
            if let shift = selectedShift, let mood = shift.postMood {
                EditPostShiftView(shift: shift, mood: mood)
            }
        }
        .sheet(isPresented: $showingQuickMode) {
            QuickCheckInView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Date Selector

    private var dateSelector: some View {
        VStack(spacing: 12) {
            // Current date display
            Button(action: { showingDatePicker.toggle() }) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .foregroundStyle(Color(hex: "F59E0B"))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedDate, format: .dateTime.weekday(.wide))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(selectedDate, format: .dateTime.day().month(.wide).year())
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    if !isToday {
                        Button(action: { withAnimation { selectedDate = Date() } }) {
                            Text("Aujourd'hui")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "F59E0B"))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .foregroundStyle(.primary)

            // Date picker (expandable)
            if showingDatePicker {
                DatePicker(
                    "Sélectionner une date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color(hex: "F59E0B"))
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onChange(of: selectedDate) { _, _ in
                    showingDatePicker = false
                }
            }

            // Quick day navigation
            HStack(spacing: 8) {
                ForEach(-6...0, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let hasData = shifts.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }

                    Button(action: { withAnimation { selectedDate = date } }) {
                        VStack(spacing: 4) {
                            Text(date, format: .dateTime.weekday(.narrow))
                                .font(.caption2)
                            Text(date, format: .dateTime.day())
                                .font(.callout)
                                .fontWeight(isSelected ? .bold : .regular)

                            // Indicator dot
                            Circle()
                                .fill(hasData ? Color(hex: "10B981") : Color.clear)
                                .frame(width: 6, height: 6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color(hex: "F59E0B").opacity(0.15) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color(hex: "F59E0B") : Color.clear, lineWidth: 2)
                        )
                    }
                    .foregroundStyle(isSelected ? Color(hex: "F59E0B") : .primary)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            // SF Symbol instead of emoji
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B").opacity(0.2), Color(hex: "F59E0B").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "stethoscope")
                    .font(.system(size: 36))
                    .foregroundStyle(Color(hex: "F59E0B"))
            }

            Text("Ton rituel quotidien")
                .font(.title3)
                .fontWeight(.bold)

            Text("30 secondes pour prendre soin de toi")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Free tier limit indicator
            if !isPremium {
                Button(action: { showingPaywall = true }) {
                    HStack(spacing: 6) {
                        if remainingFreeCheckIns > 0 {
                            Text("\(remainingFreeCheckIns) check-in\(remainingFreeCheckIns > 1 ? "s" : "") restant\(remainingFreeCheckIns > 1 ? "s" : "") cette semaine")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("Limite atteinte")
                                .font(.caption)
                        }
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("Passer en illimité")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "F59E0B").opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Quick Mode

    private var quickModeButton: some View {
        Button(action: { showingQuickMode = true }) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.body)
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
        Button(action: {
            if hasCheckedIn {
                editingPreShift = true
            } else if canDoCheckIn {
                showingPreShift = true
            } else {
                showingPaywall = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(hasCheckedIn ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                        .frame(width: 52, height: 52)

                    Image(systemName: hasCheckedIn ? "checkmark" : "sun.horizon.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Avant le shift")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(hasCheckedIn ? "Complété · Toucher pour modifier" : "Comment tu te sens ?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: hasCheckedIn ? "pencil" : "chevron.right")
                    .font(.body)
                    .foregroundStyle(hasCheckedIn ? Color(hex: "F59E0B") : Color(.tertiaryLabel))
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(hasCheckedIn ? Color(hex: "10B981").opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .cardShadow()
        }
    }

    // MARK: - Check-out Card

    private var checkOutCard: some View {
        Button(action: {
            if hasCheckedOut {
                editingPostShift = true
            } else if canDoCheckIn {
                showingPostShift = true
            } else {
                showingPaywall = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(hasCheckedOut ? Color(hex: "10B981") : Color(hex: "8B5CF6"))
                        .frame(width: 52, height: 52)

                    Image(systemName: hasCheckedOut ? "checkmark" : "moon.stars.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Après le shift")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(hasCheckedOut ? "Complété · Toucher pour modifier" : "Comment s'est passée ta journée ?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: hasCheckedOut ? "pencil" : "chevron.right")
                    .font(.body)
                    .foregroundStyle(hasCheckedOut ? Color(hex: "F59E0B") : Color(.tertiaryLabel))
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(hasCheckedOut ? Color(hex: "10B981").opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .cardShadow()
        }
        .disabled(!hasCheckedIn && !hasCheckedOut)
        .opacity((!hasCheckedIn && !hasCheckedOut) ? 0.5 : 1)
    }

    // MARK: - Summary Card

    @ViewBuilder
    private var summaryCard: some View {
        if let shift = selectedShift {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(Color(hex: "F59E0B"))
                    Text("Résumé")
                        .font(.headline)
                }

                if let pre = shift.preMood {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sun.horizon.fill")
                                .foregroundStyle(Color(hex: "F59E0B"))
                            Text("Avant le shift")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        HStack(spacing: 16) {
                            MoodIndicator(icon: "bolt.fill", value: pre.energy, label: "Énergie", color: Color(hex: "10B981"))
                            MoodIndicator(icon: "brain.head.profile", value: pre.stress, label: "Charge", color: Color(hex: "8B5CF6"))
                            MoodIndicator(icon: "heart.fill", value: pre.motivation, label: "Humeur", color: Color(hex: "F59E0B"))
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "F59E0B").opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let post = shift.postMood {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(Color(hex: "8B5CF6"))
                            Text("Après le shift")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        HStack(spacing: 16) {
                            if let fatigue = post.fatigue {
                                MoodIndicator(icon: "battery.50", value: fatigue, label: "Fatigue", color: Color(hex: "EF4444"))
                            }
                            if let load = post.emotionalLoad {
                                MoodIndicator(icon: "heart.fill", value: load, label: "Charge émo.", color: Color(hex: "8B5CF6"))
                            }
                            if let sat = post.satisfaction {
                                MoodIndicator(icon: "star.fill", value: sat, label: "Satisfaction", color: Color(hex: "F59E0B"))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "8B5CF6").opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .cardShadow()
        }
    }
}

// MARK: - Mood Indicator

struct MoodIndicator: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
