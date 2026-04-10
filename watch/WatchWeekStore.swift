import Foundation
import Observation

@Observable
class WatchWeekStore {
    var firstWeekday: Int {
        didSet { UserDefaults.standard.set(firstWeekday, forKey: "firstWeekday") }
    }

    var currentDate = Date()
    var navigationOffset = 0

    // MARK: - Computed Properties

    var calendar: Calendar {
        .weekCalendar(firstWeekday: firstWeekday)
    }

    var displayDate: Date {
        if navigationOffset == 0 { return currentDate }
        return calendar.date(byAdding: .weekOfYear, value: navigationOffset, to: currentDate) ?? currentDate
    }

    var weekNumber: Int { displayDate.weekNumber(using: calendar) }
    var year: Int { displayDate.yearForWeekOfYear(using: calendar) }

    var weekRangeString: String {
        let range = displayDate.weekDateRange(using: calendar)
        return Date.formatWeekRange(start: range.start, end: range.end)
    }

    var todayWeekNumber: Int { currentDate.weekNumber(using: calendar) }
    var isNavigatingAway: Bool { navigationOffset != 0 }

    var dayOfWeekString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: currentDate)
    }

    var weeksRemainingInYear: Int {
        let current = currentDate.weekNumber(using: calendar)
        let total = totalWeeksIn(year: currentDate.yearForWeekOfYear(using: calendar))
        return max(0, total - current)
    }

    // MARK: - Init

    init() {
        self.firstWeekday = UserDefaults.standard.object(forKey: "firstWeekday") as? Int ?? 2
    }

    // MARK: - Actions

    func navigateForward() { navigationOffset += 1 }
    func navigateBack() { navigationOffset -= 1 }
    func jumpToToday() { navigationOffset = 0 }

    // MARK: - Private

    private func totalWeeksIn(year: Int) -> Int {
        var comps = DateComponents()
        comps.year = year
        comps.month = 12
        comps.day = 28
        guard let dec28 = Calendar.current.date(from: comps) else { return 52 }
        return dec28.weekNumber(using: calendar)
    }
}
