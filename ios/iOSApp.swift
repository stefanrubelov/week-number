import SwiftUI

@main
struct WeekNumberiOSApp: App {
    @State private var store = iOSWeekStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(store: store)
            }
        }
    }
}
