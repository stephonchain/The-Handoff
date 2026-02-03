import Foundation

enum AppConstants {
    static let appName = "The Handoff"
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
}
