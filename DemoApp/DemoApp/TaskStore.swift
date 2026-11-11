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
            loadError = "Saved tasks could not be loaded. Your saved data has been preserved. Adding tasks is disabled until the data can be recovered."
        }
    }

    static func normalizedTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @discardableResult
    func addTask(title: String) -> Bool {
        let title = Self.normalizedTitle(title)
        guard loadError == nil, !title.isEmpty else { return false }
        let updated = tasks + [TaskItem(title: title)]
        guard let data = try? JSONEncoder().encode(updated) else { return false }
        defaults.set(data, forKey: Self.storageKey)
        tasks = updated
        return true
    }
}
