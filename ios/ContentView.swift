import SwiftUI

struct ContentView: View {
    @Bindable var store: iOSWeekStore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. Current week card
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Week \(store.weekNumber)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        Text(String(store.year))
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    Text(store.weekRangeString)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)

                Divider().padding(.horizontal)

                // 2. Week stats
                VStack(alignment: .leading, spacing: 4) {
                    Label(store.dayOfWeekString, systemImage: "calendar")
                    Label("\(store.weeksRemainingInYear) weeks left in \(String(store.todayYear))", systemImage: "hourglass")
                    Label(store.quarterInfo, systemImage: "chart.bar")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 12)

                Divider().padding(.horizontal)

                // 3. Week navigation
                WeekNavView(store: store)
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                Divider().padding(.horizontal)

                // 4. Mini calendar
                MiniCalendarView(store: store)
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                Divider().padding(.horizontal)

                // 5. Settings toggle
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            store.showSettings.toggle()
                        }
                    } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(store.showSettings ? .primary : .secondary)
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                if store.showSettings {
                    Divider().padding(.horizontal)
                    SettingsView(store: store)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
