import SwiftUI

struct SettingsView: View {
    @Bindable var store: WeekStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Week start day
            HStack {
                Text("Week starts on")
                    .font(.caption)
                Spacer()
                Picker("", selection: $store.firstWeekday) {
                    Text("Monday").tag(2)
                    Text("Sunday").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            // Menu bar format
            HStack {
                Text("Menu bar format")
                    .font(.caption)
                Spacer()
                Picker("", selection: $store.menuBarFormat) {
                    ForEach(MenuBarFormat.allCases, id: \.self) { format in
                        Text(format.example).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            // Launch at login
            Toggle(isOn: $store.launchAtLogin) {
                Text("Launch at login")
                    .font(.caption)
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
