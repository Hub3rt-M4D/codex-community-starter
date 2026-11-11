import SwiftUI

@main
struct DemoAppApp: App {
    @State private var store: TaskStore

    init() {
        let defaults: UserDefaults
        // UI tests use a dedicated suite on every launch, including relaunches.
        if let suite = ProcessInfo.processInfo.environment["TASK_TRACKER_TEST_SUITE"],
           suite.hasPrefix("TaskTracker.UITests.") {
            defaults = UserDefaults(suiteName: suite)!
            if ProcessInfo.processInfo.environment["TASK_TRACKER_RESET"] == "1" {
                defaults.removePersistentDomain(forName: suite)
            }
            if ProcessInfo.processInfo.environment["TASK_TRACKER_CORRUPT"] == "1" {
                defaults.set(Data("invalid JSON".utf8), forKey: TaskStore.storageKey)
            }
        } else {
            defaults = .standard
        }
        _store = State(initialValue: TaskStore(defaults: defaults))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
