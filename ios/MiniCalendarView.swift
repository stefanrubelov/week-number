import SwiftUI

struct MiniCalendarView: View {
    var store: iOSWeekStore
    @State private var calendarMonth: Date = Date()
    @State private var goToText: String = ""
    @State private var goToError: Bool = false

    private var displayCal: Calendar { Calendar.current }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            monthHeader
            weekdayRow.padding(.top, 6)
            dayGrid.padding(.top, 2)
            goToField.padding(.top, 10)
        }
        .onAppear { calendarMonth = monthStart(of: store.displayDate) }
        .onChange(of: store.displayDate) { _, newDate in
            calendarMonth = monthStart(of: newDate)
        }
    }

    private var monthHeader: some View {
        HStack(spacing: 0) {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left").frame(width: 32, height: 32)
            }
            .buttonStyle(.plain).foregroundStyle(.secondary)
            Spacer()
            Text(calendarMonth, format: .dateTime.month(.wide).year())
                .font(.subheadline.weight(.semibold))
            Spacer()
            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right").frame(width: 32, height: 32)
            }
            .buttonStyle(.plain).foregroundStyle(.secondary)
        }
    }

    private var weekdayRow: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        return LazyVGrid(columns: cols, spacing: 0) {
            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
            }
        }
    }

    private var dayGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        return LazyVGrid(columns: cols, spacing: 2) {
            ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, day in
                DayCell(
                    date: day.date,
                    isCurrentMonth: day.isCurrentMonth,
                    isToday: displayCal.isDateInToday(day.date),
                    isInActiveWeek: isInActiveWeek(day.date)
                ) {
                    store.navigateToDate(day.date)
                }
            }
        }
    }

    private var goToField: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                TextField("Go to date…", text: $goToText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { commitGoTo() }
                    .onChange(of: goToText) { _, _ in goToError = false }
                if !goToText.isEmpty {
                    Button {
                        goToText = ""
                        goToError = false
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            if goToError {
                Text("Try: 15 aug, 2026-08-15, or 15/08/2026")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var weekdayLabels: [String] {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        let offset = store.firstWeekday - 1
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }

    private typealias CalDay = (date: Date, isCurrentMonth: Bool)

    private var calendarDays: [CalDay] {
        var comps = displayCal.dateComponents([.year, .month], from: calendarMonth)
        comps.day = 1
        guard let firstOfMonth = displayCal.date(from: comps) else { return [] }
        let firstWeekday = displayCal.component(.weekday, from: firstOfMonth)
        let leadingCount = (firstWeekday - store.firstWeekday + 7) % 7
        let currentMonth = displayCal.component(.month, from: calendarMonth)
        var days: [CalDay] = []
        for i in stride(from: -leadingCount, to: 42 - leadingCount, by: 1) {
            if let d = displayCal.date(byAdding: .day, value: i, to: firstOfMonth) {
                days.append((date: d, isCurrentMonth: displayCal.component(.month, from: d) == currentMonth))
            }
        }
        return days
    }

    private func isInActiveWeek(_ date: Date) -> Bool {
        let range = store.displayDate.weekDateRange(using: store.calendar)
        return date >= range.start && date <= range.end
    }

    private func monthStart(of date: Date) -> Date {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: comps) ?? date
    }

    private func shiftMonth(_ value: Int) {
        if let m = displayCal.date(byAdding: .month, value: value, to: calendarMonth) {
            calendarMonth = m
        }
    }

    private func commitGoTo() {
        guard let date = Date.parseNatural(goToText) else { goToError = true; return }
        store.navigateToDate(date)
        calendarMonth = monthStart(of: date)
        goToText = ""
    }
}

private struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isInActiveWeek: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background {
                    if isToday {
                        Circle().fill(Color.accentColor).padding(2)
                    } else if isInActiveWeek {
                        RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.15))
                    }
                }
                .foregroundStyle(isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        }
        .buttonStyle(.plain)
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }
}
