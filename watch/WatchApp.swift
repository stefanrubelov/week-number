import SwiftUI

@main
struct WeekNumberWatchApp: App {
    @State private var store = WatchWeekStore()

    var body: some Scene {
        WindowGroup {
            WatchContentView(store: store)
        }
    }
}
