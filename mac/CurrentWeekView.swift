import SwiftUI

struct CurrentWeekView: View {
    var store: WeekStore

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Week \(store.weekNumber)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text(String(store.year))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text(store.weekRangeString)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
