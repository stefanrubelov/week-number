import SwiftUI

struct WeekNavView: View {
    var store: iOSWeekStore

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    store.navigateBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(spacing: 2) {
                    if store.isNavigatingAway {
                        Text("Week \(store.weekNumber), \(String(store.year))")
                            .font(.callout.weight(.medium))
                        Text(store.weekRangeString)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("This week")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button {
                    store.navigateForward()
                } label: {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }

            if store.isNavigatingAway {
                Button("Jump to today") {
                    store.jumpToToday()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
