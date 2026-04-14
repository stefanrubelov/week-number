import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct WeekEntry: TimelineEntry {
    let date: Date
    let weekNumber: Int
    let year: Int
    let weekRangeString: String
    let weeksRemaining: Int
}

// MARK: - Timeline Provider

struct WeekProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeekEntry {
        makeEntry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekEntry) -> Void) {
        completion(makeEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeekEntry>) -> Void) {
        let entry = makeEntry(for: Date())
        let cal = Calendar.current
        let tomorrow = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: Date())!)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }

    func makePreviewEntry() -> WeekEntry {
        makeEntry(for: Date())
    }

    private func makeEntry(for date: Date) -> WeekEntry {
        let firstWeekday = UserDefaults.standard.object(forKey: "firstWeekday") as? Int ?? 2
        let calendar = Calendar.weekCalendar(firstWeekday: firstWeekday)
        let weekNumber = date.weekNumber(using: calendar)
        let year = date.yearForWeekOfYear(using: calendar)
        let range = date.weekDateRange(using: calendar)
        let rangeString = Date.formatWeekRange(start: range.start, end: range.end)
        let total = totalWeeksIn(year: year, calendar: calendar)
        return WeekEntry(
            date: date,
            weekNumber: weekNumber,
            year: year,
            weekRangeString: rangeString,
            weeksRemaining: max(0, total - weekNumber)
        )
    }

    private func totalWeeksIn(year: Int, calendar: Calendar) -> Int {
        var comps = DateComponents()
        comps.year = year; comps.month = 12; comps.day = 28
        guard let dec28 = Calendar.current.date(from: comps) else { return 52 }
        return dec28.weekNumber(using: calendar)
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: WeekEntry

    var body: some View {
        VStack(spacing: 4) {
            Text("Week \(entry.weekNumber)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
            Text(entry.weekRangeString)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: WeekEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Week \(entry.weekNumber)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }
                Text(entry.weekRangeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.weeksRemaining)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("weeks left")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Entry View

struct WeekWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WeekEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget + Bundle

struct WeekWidget: Widget {
    let kind = "WeekWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeekProvider()) { entry in
            WeekWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Week Number")
        .description("Shows the current ISO week number.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview("Small", as: .systemSmall) {
    WeekWidget()
} timeline: {
    WeekProvider().makePreviewEntry()
}

#Preview("Medium", as: .systemMedium) {
    WeekWidget()
} timeline: {
    WeekProvider().makePreviewEntry()
}

@main
struct WeekWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeekWidget()
    }
}
