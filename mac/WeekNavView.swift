import SwiftUI

struct WeekNavView: View {
    var store: WeekStore

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    store.navigateBack()
                } label: {
                    Image(systemName: "chevron.left")
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
                }
                .buttonStyle(.plain)
            }

            if store.isNavigatingAway {
                Button("Jump to today") {
                    store.jumpToToday()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
}
