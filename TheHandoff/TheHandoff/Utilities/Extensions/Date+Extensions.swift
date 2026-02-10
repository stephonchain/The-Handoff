import Foundation

extension Date {
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear], from: self, to: now)

        if let week = components.weekOfYear, week >= 1 {
            return "\(week) week\(week > 1 ? "s" : "") ago"
        } else if let day = components.day, day >= 1 {
            return "\(day) day\(day > 1 ? "s" : "") ago"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour) hour\(hour > 1 ? "s" : "") ago"
        } else if let minute = components.minute, minute >= 1 {
            return "\(minute) minute\(minute > 1 ? "s" : "") ago"
        } else {
            return String(localized: "common_just_now")
        }
    }
}
