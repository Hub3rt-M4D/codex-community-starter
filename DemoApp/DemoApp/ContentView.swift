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
                List(store.tasks) { task in
                    Text(task.title)
                }
            }
            .navigationTitle("Tasks")
        }
    }
}

#Preview {
    ContentView(store: TaskStore(defaults: UserDefaults(suiteName: "TaskTracker.preview")!))
}
