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
                .buttonStyle(.glass)

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
                .buttonStyle(.glass)
            }

            if store.isNavigatingAway {
                Button("Jump to today") {
                    store.jumpToToday()
                }
                .buttonStyle(.glass)
                .controlSize(.small)
            }
        }
    }
}
