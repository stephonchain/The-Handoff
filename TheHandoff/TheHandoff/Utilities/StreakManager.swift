import Foundation
import SwiftUI

@Observable
final class StreakManager {
    static let shared = StreakManager()

    private let lastOpenDateKey = "lastAppOpenDate"
    private let currentStreakKey = "currentOpenStreak"
    private let longestStreakKey = "longestOpenStreak"

    var currentStreak: Int {
        get { UserDefaults.standard.integer(forKey: currentStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: currentStreakKey) }
    }

    var longestStreak: Int {
        get { UserDefaults.standard.integer(forKey: longestStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: longestStreakKey) }
    }

    private var lastOpenDate: Date? {
        get { UserDefaults.standard.object(forKey: lastOpenDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastOpenDateKey) }
    }

    var shouldShowStreakAnimation: Bool = false
    var isNewDay: Bool = false

    private init() {}

    /// Call this when the app becomes active
    func recordAppOpen() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = lastOpenDate {
            let lastDay = calendar.startOfDay(for: lastDate)

            if calendar.isDate(lastDay, inSameDayAs: today) {
                // Same day - no streak change
                isNewDay = false
                return currentStreak
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      calendar.isDate(lastDay, inSameDayAs: yesterday) {
                // Yesterday - increment streak
                currentStreak += 1
                isNewDay = true
            } else {
                // Missed a day - reset streak
                currentStreak = 1
                isNewDay = true
            }
        } else {
            // First time opening
            currentStreak = 1
            isNewDay = true
        }

        // Update longest streak
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        lastOpenDate = today
        shouldShowStreakAnimation = isNewDay

        return currentStreak
    }

    func dismissAnimation() {
        shouldShowStreakAnimation = false
    }
}

// MARK: - Streak Overlay View

struct StreakOverlayView: View {
    let streak: Int
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showFlame = false
    @State private var showNumber = false
    @State private var showMessage = false
    @State private var pulseFlame = false

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 24) {
                Spacer()

                // Animated flame with number
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "F59E0B").opacity(0.4), .clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(pulseFlame ? 1.1 : 0.9)

                    // Main flame circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(showFlame ? 1 : 0.3)
                        .opacity(showFlame ? 1 : 0)
                        .shadow(color: Color(hex: "F59E0B").opacity(0.5), radius: 20, x: 0, y: 10)

                    // Streak number
                    VStack(spacing: 0) {
                        Text("\(streak)")
                            .font(.system(size: 56, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Text(streak == 1 ? "jour" : "jours")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .scaleEffect(showNumber ? 1 : 0.5)
                    .opacity(showNumber ? 1 : 0)
                }

                // Message
                VStack(spacing: 8) {
                    Text(streakTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(streakMessage)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(showMessage ? 1 : 0)
                .offset(y: showMessage ? 0 : 20)

                Spacer()

                // Continue button
                Button(action: dismiss) {
                    Text("Continuer")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "F59E0B"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(Capsule())
                        .padding(.horizontal, 40)
                }
                .opacity(showMessage ? 1 : 0)
                .scaleEffect(showMessage ? 1 : 0.9)

                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private var streakTitle: String {
        if streak == 1 {
            return "Bienvenue !"
        } else if streak < 3 {
            return "Tu reviens !"
        } else if streak < 7 {
            return "Belle constance !"
        } else if streak < 14 {
            return "Une semaine !"
        } else if streak < 30 {
            return "Impressionnant !"
        } else {
            return "Incroyable !"
        }
    }

    private var streakMessage: String {
        if streak == 1 {
            return "C'est ton premier jour. Prends soin de toi."
        } else if streak < 3 {
            return "Continue comme ça, chaque jour compte."
        } else if streak < 7 {
            return "\(streak) jours de suite ! Ta régularité paie."
        } else if streak < 14 {
            return "Une semaine complète ! Tu construis une vraie habitude."
        } else if streak < 30 {
            return "\(streak) jours ! Tu prends soin de toi avec constance."
        } else {
            return "\(streak) jours de suite ! Tu es un exemple de persévérance."
        }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showFlame = true
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            showNumber = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            showMessage = true
        }

        // Continuous pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseFlame = true
        }
    }

    private func dismiss() {
        HapticManager.shared.impact(style: .light)
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
