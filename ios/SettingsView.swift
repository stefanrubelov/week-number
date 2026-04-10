import SwiftUI

struct SettingsView: View {
    @Bindable var store: iOSWeekStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Week starts on")
                    .font(.subheadline)
                Spacer()
                Picker("", selection: $store.firstWeekday) {
                    Text("Monday").tag(2)
                    Text("Sunday").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
        }
    }
}
