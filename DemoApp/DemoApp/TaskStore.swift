import Foundation
import Observation

@MainActor
@Observable
final class TaskStore {
    static let storageKey = "tasks"

    private(set) var tasks: [TaskItem] = []
    private(set) var loadError: String?
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
        guard let savedValue = defaults.object(forKey: Self.storageKey) else { return }
        do {
            guard let data = savedValue as? Data else {
                throw CocoaError(.coderReadCorrupt)
            }
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            loadError = "Saved tasks could not be loaded. Your saved data has been preserved. Changes are disabled until the data can be recovered."
        }
    }

    static func normalizedTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var pendingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    @discardableResult
    func toggleTask(id: UUID) -> Bool {
        guard loadError == nil, let index = tasks.firstIndex(where: { $0.id == id }) else { return false }
        var updated = tasks
        updated[index].isCompleted.toggle()
        return save(updated)
    }

    @discardableResult
    func addTask(title: String) -> Bool {
        let title = Self.normalizedTitle(title)
        guard loadError == nil, !title.isEmpty else { return false }
        let updated = tasks + [TaskItem(title: title)]
        return save(updated)
    }

    private func save(_ updated: [TaskItem]) -> Bool {
        guard let data = try? JSONEncoder().encode(updated) else { return false }
        defaults.set(data, forKey: Self.storageKey)
        tasks = updated
        return true
    }
}
