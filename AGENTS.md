# Workshop project

This repository contains a SwiftUI iOS starter app at `DemoApp/DemoApp.xcodeproj`.
The app sources are in `DemoApp/DemoApp/`; unit tests and UI tests are in
`DemoApp/DemoAppTests/` and `DemoApp/DemoAppUITests/`. The initial screen displays
the task tracker. It adds and persists tasks; completion controls, completion
styling, and the pending counter are reserved for `tasks/complete-task.md`.

## Workflow

- Use `plan-task` to inspect a request and propose a bounded plan with acceptance
  checks before implementation. Resolve material ambiguity and agree on scope
  before changing application code.
- Use `implement-task` to carry out the agreed plan, add meaningful tests where
  appropriate, and run relevant checks.
- Use `review-changes` to inspect changes for concrete defects and unmet
  acceptance criteria without editing files.
- Use `prepare-pr` to inspect publication scope and draft a PR description with
  actual verification evidence.

## Working rules

- Preserve unrelated changes; inspect existing work before editing.
- Use tests appropriate to the behavior changed. Record the checks run and their
  actual results, including failures, skipped checks, and unverified behavior.
  Never claim a check passed unless it ran successfully.
- Never commit credentials, tokens, private keys, or other secrets.
- Obtain explicit user authorization before committing, pushing, or creating a
  PR. Authorization for one action does not authorize the others.
- Never merge automatically.
