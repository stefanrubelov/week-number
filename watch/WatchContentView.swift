import SwiftUI

struct WatchContentView: View {
    var store: WatchWeekStore

    @State private var crownValue = 0.0

    var body: some View {
        VStack(spacing: 6) {
            Text("W\(store.weekNumber)")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text(String(store.year))
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(store.weekRangeString)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 4)

            Text("\(store.weeksRemainingInYear) weeks left in \(String(store.year))")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Button { store.navigateBack() } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)

                Spacer()

                if store.isNavigatingAway {
                    Button("Today") {
                        store.jumpToToday()
                    }
                    .font(.caption2)
                    .buttonStyle(.glass)
                } else {
                    Text(store.dayOfWeekString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button { store.navigateForward() } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }
        }
        .padding(.horizontal)
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: -10000,
            through: 10000,
            by: 1,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { oldValue, newValue in
            let diff = Int(newValue) - Int(oldValue)

            if diff > 0 {
                store.navigateForward()
            } else if diff < 0 {
                store.navigateBack()
            }
        }
    }
}
