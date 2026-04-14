import SwiftUI

struct PopoverView: View {
    @Bindable var store: WeekStore

    var body: some View {
        VStack(spacing: 0) {
            // 1. Current Week Card
            CurrentWeekView(store: store)

            Divider().padding(.horizontal)

            // 2. Week Stats
            VStack(alignment: .leading, spacing: 4) {
                Label(store.dayOfWeekString, systemImage: "calendar")
                Label("\(store.weeksRemainingInYear) weeks left in \(String(store.todayYear))", systemImage: "hourglass")
                Label(store.quarterInfo, systemImage: "chart.bar")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider().padding(.horizontal)

            // 3. Prev / Next Navigation
            WeekNavView(store: store)
                .padding(.horizontal)
                .padding(.vertical, 10)

            Divider().padding(.horizontal)

            // 4. Mini Calendar
            MiniCalendarView(store: store)
                .padding(.horizontal)
                .padding(.vertical, 10)

            Divider().padding(.horizontal)

            // 5. Settings gear footer
            HStack {
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        store.showSettings.toggle()
                    }
                } label: {
                    Image(systemName: "gear")
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            if store.showSettings {
                Divider().padding(.horizontal)
                SettingsView(store: store)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: 300)
    }
}
