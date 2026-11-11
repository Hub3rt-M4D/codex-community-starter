# Task tracker workshop starter

A SwiftUI iOS app for practicing a repeatable Codex workflow: plan, implement,
review, and prepare a pull request.

## Baseline

The app adds tasks from a text field and displays them in insertion order.
Titles are trimmed; blank titles are rejected. Each task has a stable UUID,
title, and completion flag. Tasks are stored locally as JSON in `UserDefaults`.
Unreadable saved data is preserved: the app displays an error and blocks additions.

Completion controls, completed-task styling, and a pending counter are deliberately
absent. Implement them during the [completion exercise](tasks/complete-task.md).
The baseline already saves and restores completion flags.

## Prerequisites

- macOS compatible with your installed Xcode version.
- Xcode 26.2 or later, with an iOS 26.2 or later simulator runtime. The project
  was created with Xcode 26.2 and targets iOS 26.2.
- Authenticated Codex access in a client supporting local projects and skills.
  Follow the [official authentication instructions](https://learn.chatgpt.com/docs/auth?surface=cli).
  Keep authentication data outside this project.

The app uses Apple frameworks and has no third-party dependencies. Running it
does not require Codex authentication or an OpenAI API key; Codex access is for
the guided workshop workflow.

## Open, build, test, and run

Run commands from the `codex-community-starter` directory.

```sh
open DemoApp/DemoApp.xcodeproj
```

In Xcode, select the **DemoApp** scheme and an available iOS simulator. Use
**Product > Build** (Command-B), **Product > Run** (Command-R), and
**Product > Test** (Command-U). Run displays the task list and Add field.
For a physical device, configure your own signing team and bundle identifiers.

For command-line use, confirm Xcode is selected with `xcode-select -p`, then
inspect the project and available destinations:

```sh
xcodebuild -list -project DemoApp/DemoApp.xcodeproj
xcodebuild -showdestinations -project DemoApp/DemoApp.xcodeproj -scheme DemoApp
```

Set `WORKSHOP_SIMULATOR_ID` to an available simulator UUID from that output.
Prefer a disposable simulator for workshop tests.

```sh
export WORKSHOP_SIMULATOR_ID='REPLACE_WITH_AVAILABLE_SIMULATOR_UUID'

xcodebuild build \
  -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug \
  -destination "platform=iOS Simulator,id=$WORKSHOP_SIMULATOR_ID" \
  -derivedDataPath .build/Debug CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug \
  -destination "platform=iOS Simulator,id=$WORKSHOP_SIMULATOR_ID" \
  -derivedDataPath .build/Debug -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES

xcodebuild test \
  -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Release \
  -destination "platform=iOS Simulator,id=$WORKSHOP_SIMULATOR_ID" \
  -derivedDataPath .build/Release -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES
```

Run tests sequentially and wait for each command to finish. Release needs
testability because unit tests use `@testable import DemoApp`; this setting does
not enable `DEBUG`. Unit tests use Swift Testing; UI tests use XCTest.

Ordinary launches use normal app storage. Unit tests inject unique suites, and
UI tests explicitly select unique `TaskTracker.UITests.*` suites in both Debug
and Release. Relaunches retain the suite, and cleanup resets only that suite.
Leave `TASK_TRACKER_TEST_SUITE`, `TASK_TRACKER_RESET`, and `TASK_TRACKER_CORRUPT`
out of ordinary Run configurations.

## Project-local Codex harness

Here, “harness” means the checked-in guidance, task brief, skills, and verification
workflow around the app. It is not an additional service or dependency.

Open this directory as the Codex project. [AGENTS.md](AGENTS.md) defines the
workflow and publication boundaries. Four skills live in `.agents/skills/`;
invoke one by name, for example `$plan-task`. See the
[official skills documentation](https://learn.chatgpt.com/docs/build-skills)
for skill discovery and invocation.

| Skill | Purpose | Example prompt |
| --- | --- | --- |
| [plan-task](.agents/skills/plan-task/SKILL.md) | Inspect requirements; propose scope and acceptance checks before editing app code. | `Use $plan-task to plan tasks/complete-task.md. Do not implement yet.` |
| [implement-task](.agents/skills/implement-task/SKILL.md) | Carry out the agreed plan and run relevant checks. | `Use $implement-task to implement the agreed completion plan with tests. Do not commit, push, or publish.` |
| [review-changes](.agents/skills/review-changes/SKILL.md) | Inspect code, tests, and changes without editing. | `Use $review-changes to review against tasks/complete-task.md. Do not modify files.` |
| [prepare-pr](.agents/skills/prepare-pr/SKILL.md) | Inspect publication scope and draft a PR description using actual evidence. | `Use $prepare-pr to draft a PR title and description. Do not stage, commit, push, or create a PR.` |

Use the [exact workshop prompts](docs/demo-prompts.md) in order. Review the plan
and explicitly agree before requesting implementation. PR preparation produces
a draft; committing, pushing, and creating a PR each require separate explicit
authorization. Never merge automatically.

## Optional Jira integration

Jira is optional. The local [task brief](tasks/complete-task.md) contains everything
needed for the exercise. No Jira connection or credentials are included.
If you choose a Jira connector, configure authentication locally and separately
authorize access to the intended project and issue. Authorize any Jira write,
such as a comment or status change, explicitly. The workshop prompts do not
authorize external reads or writes.

## Reuse in another stack

Reuse `AGENTS.md`, the four skill folders, the task-brief pattern, and the prompt
sequence in another project. Replace SwiftUI paths, build commands, and acceptance
checks with that stack's equivalents. Keep the principles: inspect existing work,
agree on scope, test observable behavior, review independently, and prepare
publication from actual evidence. The instruction files require no iOS runtime.

## Distribution scope

Distribute only the contents of `codex-community-starter`, including the hidden
`.agents` directory. Check `git rev-parse --show-toplevel` before selecting files:
this directory may be inside a larger repository. Include source, tests, project
files, docs, and skills; exclude user state, build products, test results,
credentials, and local configuration. `.gitignore` does not remove files already
in an index. Review staged contents before any separately authorized publication.

## License

Licensed under the [MIT License](LICENSE). Copyright (c) 2026 Hubert Madrian.
