import SwiftUI

struct ContentView: View {
    let store: TaskStore
    @State private var title = ""

    var body: some View {
        NavigationStack {
            VStack {
                if let error = store.loadError {
                    Text(error)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("loadError")
                        .padding()
                }
                HStack {
                    TextField("New task", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("taskTitle")
                    Button("Add") {
                        if store.addTask(title: title) {
                            title = ""
                        }
                    }
                    .disabled(store.loadError != nil || TaskStore.normalizedTitle(title).isEmpty)
                }
                .padding(.horizontal)
                Text("Pending: \(store.pendingCount)")
                    .accessibilityIdentifier("pendingCount")
                List(store.tasks) { task in
                    HStack {
                        Button {
                            store.toggleTask(id: task.id)
                        } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("\(task.isCompleted ? "Mark incomplete" : "Mark complete"): \(task.title)")
                        .accessibilityValue(task.isCompleted ? "Completed" : "Incomplete")
                        .accessibilityIdentifier("completion-\(task.id.uuidString)")
                        .disabled(store.loadError != nil)
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                        if task.isCompleted {
                            Text("Completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
        }
    }
}

#Preview {
    ContentView(store: TaskStore(defaults: UserDefaults(suiteName: "TaskTracker.preview")!))
}
