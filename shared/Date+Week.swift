import Foundation

extension Calendar {
    /// Creates a calendar configured for week calculations.
    /// Uses minimumDaysInFirstWeek = 4 (ISO 8601 standard).
    static func weekCalendar(firstWeekday: Int = 2) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = firstWeekday
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }
}

extension Date {
    func weekNumber(using calendar: Calendar) -> Int {
        calendar.component(.weekOfYear, from: self)
    }

    func yearForWeekOfYear(using calendar: Calendar) -> Int {
        calendar.component(.yearForWeekOfYear, from: self)
    }

    func weekDateRange(using calendar: Calendar) -> (start: Date, end: Date) {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.weekday = calendar.firstWeekday
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 6, to: start)!
        return (start, end)
    }

    static func formatWeekRange(start: Date, end: Date) -> String {
        let cal = Calendar.current
        let startYear = cal.component(.year, from: start)
        let endYear = cal.component(.year, from: end)
        let startMonth = cal.component(.month, from: start)
        let endMonth = cal.component(.month, from: end)

        let fmt = DateFormatter()
        fmt.locale = Locale.current

        if startYear != endYear {
            fmt.dateFormat = "EEE d MMM yyyy"
            return "\(fmt.string(from: start)) – \(fmt.string(from: end))"
        } else if startMonth != endMonth {
            fmt.dateFormat = "EEE d MMM"
            let s = fmt.string(from: start)
            fmt.dateFormat = "EEE d MMM yyyy"
            return "\(s) – \(fmt.string(from: end))"
        } else {
            fmt.dateFormat = "EEE d"
            let s = fmt.string(from: start)
            fmt.dateFormat = "EEE d MMM yyyy"
            return "\(s) – \(fmt.string(from: end))"
        }
    }

    static func parseNatural(_ input: String) -> Date? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formats: [String] = [
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "d MMM yyyy",
            "d MMM",
            "MMM d yyyy",
            "MMM d",
            "d MMMM yyyy",
            "d MMMM",
            "MMMM d yyyy",
            "MMMM d",
        ]

        let currentYear = Calendar.current.component(.year, from: Date())

        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: trimmed) {
                if !format.contains("yyyy") {
                    var components = Calendar.current.dateComponents([.month, .day], from: date)
                    components.year = currentYear
                    if let adjusted = Calendar.current.date(from: components) {
                        return adjusted
                    }
                }
                return date
            }
        }

        return nil
    }
}
