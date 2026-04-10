import Foundation
import Observation

@Observable
class iOSWeekStore {
    var firstWeekday: Int {
        didSet { UserDefaults.standard.set(firstWeekday, forKey: "firstWeekday") }
    }

    var currentDate = Date()
    var navigationOffset = 0
    var showSettings = false

    var calendar: Calendar { .weekCalendar(firstWeekday: firstWeekday) }

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
    var todayYear: Int { currentDate.yearForWeekOfYear(using: calendar) }
    var isNavigatingAway: Bool { navigationOffset != 0 }

    var dayOfWeekString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return "Today is \(fmt.string(from: currentDate))"
    }

    var weeksRemainingInYear: Int {
        let current = currentDate.weekNumber(using: calendar)
        let total = totalWeeksIn(year: currentDate.yearForWeekOfYear(using: calendar))
        return max(0, total - current)
    }

    var quarterInfo: String {
        let month = Calendar.current.component(.month, from: currentDate)
        let quarter = (month - 1) / 3 + 1
        let quarterStartMonth = (quarter - 1) * 3 + 1
        var comps = DateComponents()
        comps.year = Calendar.current.component(.year, from: currentDate)
        comps.month = quarterStartMonth
        comps.day = 1
        guard let qStart = Calendar.current.date(from: comps) else { return "Q\(quarter)" }
        let days = Calendar.current.dateComponents([.day], from: qStart, to: currentDate).day ?? 0
        let weekInQuarter = days / 7 + 1
        return "Week \(weekInQuarter) of Q\(quarter)"
    }

    init() {
        self.firstWeekday = UserDefaults.standard.object(forKey: "firstWeekday") as? Int ?? 2
        setupNotifications()
    }

    func navigateForward() { navigationOffset += 1 }
    func navigateBack() { navigationOffset -= 1 }
    func jumpToToday() { navigationOffset = 0 }

    func navigateToDate(_ date: Date) {
        let currentWeekStart = currentDate.weekDateRange(using: calendar).start
        let targetWeekStart = date.weekDateRange(using: calendar).start
        let days = calendar.dateComponents([.day], from: currentWeekStart, to: targetWeekStart).day ?? 0
        navigationOffset = days / 7
    }

    private func totalWeeksIn(year: Int) -> Int {
        var comps = DateComponents()
        comps.year = year
        comps.month = 12
        comps.day = 28
        guard let dec28 = Calendar.current.date(from: comps) else { return 52 }
        return dec28.weekNumber(using: calendar)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
}
