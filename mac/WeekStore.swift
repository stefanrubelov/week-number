import Foundation
import Observation
import AppKit
import ServiceManagement

enum MenuBarFormat: String, CaseIterable {
    case short = "W{n}"
    case plain = "{n}"
    case long = "Wk {n}"

    func formatted(week: Int) -> String {
        switch self {
        case .short: return "W\(week)"
        case .plain: return "\(week)"
        case .long: return "Wk \(week)"
        }
    }

    var example: String {
        switch self {
        case .short: return "W14"
        case .plain: return "14"
        case .long: return "Wk 14"
        }
    }
}

@Observable
class WeekStore {
    // MARK: - Settings (persisted via UserDefaults)
    var firstWeekday: Int {
        didSet { UserDefaults.standard.set(firstWeekday, forKey: "firstWeekday") }
    }
    var menuBarFormat: MenuBarFormat {
        didSet { UserDefaults.standard.set(menuBarFormat.rawValue, forKey: "menuBarFormat") }
    }
    var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLoginItem()
        }
    }

    // MARK: - State
    var currentDate = Date()
    var navigationOffset = 0
    var showSettings = false

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
    var todayYear: Int { currentDate.yearForWeekOfYear(using: calendar) }

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

    var menuBarText: String {
        menuBarFormat.formatted(week: todayWeekNumber)
    }

    var isNavigatingAway: Bool { navigationOffset != 0 }

    // MARK: - Init
    init() {
        self.firstWeekday = UserDefaults.standard.object(forKey: "firstWeekday") as? Int ?? 2
        self.menuBarFormat = MenuBarFormat(rawValue: UserDefaults.standard.string(forKey: "menuBarFormat") ?? "") ?? .short
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        setupNotifications()
    }

    // MARK: - Actions
    func navigateForward() { navigationOffset += 1 }
    func navigateBack() { navigationOffset -= 1 }
    func jumpToToday() { navigationOffset = 0 }

    func navigateToDate(_ date: Date) {
        let currentWeekStart = currentDate.weekDateRange(using: calendar).start
        let targetWeekStart = date.weekDateRange(using: calendar).start
        let days = calendar.dateComponents([.day], from: currentWeekStart, to: targetWeekStart).day ?? 0
        navigationOffset = days / 7
    }

    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("W\(weekNumber) \(year)", forType: .string)
    }

    // MARK: - Private
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
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.currentDate = Date()
        }
    }

    private func updateLoginItem() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Login item error: \(error)")
        }
    }
}
