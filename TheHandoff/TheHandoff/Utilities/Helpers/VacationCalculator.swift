import Foundation

struct VacationCalculator {
    static func workingDaysUntil(_ date: Date, from: Date = Date()) -> Int {
        let calendar = Calendar.current
        var workingDays = 0
        var currentDate = calendar.startOfDay(for: from)
        let targetDate = calendar.startOfDay(for: date)

        while currentDate < targetDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday != 1 && weekday != 7 {
                workingDays += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return workingDays
    }
}
