import Foundation
import Testing
@testable import DemoApp

@MainActor
struct DemoAppTests {
    private func withDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
        let suite = "TaskTracker.UnitTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        try body(defaults)
    }

    @Test func addsTrimmedTasksWithUniqueIDsAndDefaultCompletion() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            #expect(store.addTask(title: "  First task \n"))
            #expect(store.addTask(title: "Second task"))
            #expect(store.tasks.map(\.title) == ["First task", "Second task"])
            #expect(store.tasks.allSatisfy { !$0.isCompleted })
            #expect(Set(store.tasks.map(\.id)).count == 2)
        }
    }

    @Test func rejectsBlankTitlesWithoutChangingSavedData() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            store.addTask(title: "Existing")
            let saved = defaults.data(forKey: TaskStore.storageKey)
            for title in ["", " ", "\t", "\n", " \t\n "] {
                #expect(!store.addTask(title: title))
            }
            #expect(store.tasks.count == 1)
            #expect(defaults.data(forKey: TaskStore.storageKey) == saved)
        }
    }

    @Test func persistsAdditionsAcrossFreshStores() {
        withDefaults { defaults in
            let first = TaskStore(defaults: defaults)
            #expect(first.tasks.isEmpty)
            first.addTask(title: "One")
            first.addTask(title: "Two")
            let reloaded = TaskStore(defaults: defaults)
            #expect(reloaded.loadError == nil)
            #expect(reloaded.tasks == first.tasks)
        }
    }

    @Test func restoresAllModelFields() throws {
        try withDefaults { defaults in
            let items = [
                TaskItem(title: "Saved completed", isCompleted: true),
                TaskItem(title: "Saved pending", isCompleted: false)
            ]
            defaults.set(try JSONEncoder().encode(items), forKey: TaskStore.storageKey)
            let store = TaskStore(defaults: defaults)
            #expect(store.tasks == items)
            #expect(store.addTask(title: "Another task"))
            let added = try #require(store.tasks.last)
            #expect(added.title == "Another task")
            #expect(!added.isCompleted)
            #expect(!items.map(\.id).contains(added.id))
            let reloaded = TaskStore(defaults: defaults)
            #expect(reloaded.loadError == nil)
            #expect(reloaded.tasks == items + [added])
        }
    }

    @Test func togglesOnlySelectedIdentityAndPersistsBothDirections() throws {
        try withDefaults { defaults in
            let items = [
                TaskItem(title: "Same title", isCompleted: true),
                TaskItem(title: "Same title"),
                TaskItem(title: "Neighbor")
            ]
            defaults.set(try JSONEncoder().encode(items), forKey: TaskStore.storageKey)
            let store = TaskStore(defaults: defaults)
            #expect(store.pendingCount == 2)
            #expect(store.toggleTask(id: items[1].id))
            var expected = items
            expected[1].isCompleted = true
            #expect(store.tasks == expected)
            #expect(store.pendingCount == 1)
            let reloaded = TaskStore(defaults: defaults)
            #expect(reloaded.tasks == expected)
            #expect(reloaded.toggleTask(id: items[1].id))
            #expect(reloaded.pendingCount == 2)
            #expect(reloaded.addTask(title: "  Added \n"))
            let added = try #require(reloaded.tasks.last)
            #expect(added.title == "Added")
            #expect(!added.isCompleted)
            #expect(reloaded.pendingCount == 3)
            let final = TaskStore(defaults: defaults)
            #expect(final.tasks == items + [added])
            #expect(final.pendingCount == 3)
        }
    }

    @Test func emptyCountAndUnknownIdentityDoNotMutateStorage() {
        withDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            #expect(store.pendingCount == 0)
            #expect(!store.toggleTask(id: UUID()))
            #expect(defaults.object(forKey: TaskStore.storageKey) == nil)
            #expect(store.addTask(title: "Task"))
            let saved = defaults.data(forKey: TaskStore.storageKey)
            #expect(!store.toggleTask(id: UUID()))
            #expect(store.pendingCount == 1)
            #expect(defaults.data(forKey: TaskStore.storageKey) == saved)
        }
    }

    @Test func preservesUnreadableDataAndBlocksAdditions() {
        withDefaults { defaults in
            for value: Any in [Data("broken JSON".utf8), "wrong storage type", Data("{}".utf8)] {
                defaults.set(value, forKey: TaskStore.storageKey)
                let before = defaults.object(forKey: TaskStore.storageKey) as? NSObject
                let store = TaskStore(defaults: defaults)
                #expect(store.loadError != nil)
                #expect(!store.addTask(title: "Must not overwrite"))
                #expect(!store.toggleTask(id: UUID()))
                #expect(store.pendingCount == 0)
                #expect(store.tasks.isEmpty)
                #expect(defaults.object(forKey: TaskStore.storageKey) as? NSObject == before)
            }
        }
    }
}
