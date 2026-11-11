# Exercise: complete a task

Implement completion in the existing SwiftUI task tracker. This document is a
workshop brief; the starter intentionally does not implement the exercise.

## Acceptance criteria

- A user can toggle an individual task from incomplete to complete and back.
  The action affects only the selected task and has an accessible label/state.
- Completed tasks look distinct, using more than color alone. Both completed
  and incomplete tasks remain visible in their existing order.
- A visible pending count equals the number of incomplete tasks. It is zero for
  an empty list and updates immediately when adding or toggling in either direction.
- Completion survives app termination and restart, including toggling a task
  back to incomplete before restart.
- Loading saved tasks and toggling or adding a task preserves existing IDs,
  titles, ordering, and unrelated completion flags. Use the existing
  `TaskItem.isCompleted` field and JSON storage format.
- Addition still trims titles, rejects blank titles, and creates exactly one
  task per successful addition.
- Unreadable saved data remains untouched. Show the existing load error and
  block all mutations, including completion changes, until it can be recovered.

## Constraints and verification

Use existing app and test targets. Add no dependencies or unrelated features
such as deletion, sorting, accounts, sync, or a storage migration. Preserve
unrelated local work.

Add meaningful unit tests for both toggle directions, target-task identity,
unchanged neighboring tasks, pending counts, load/add/toggle/reload sequences,
and mutation blocking for unreadable data. Add UI tests for the completion
control, distinct completion presentation, pending count updates, and persistence
across relaunch. Keep every test isolated from normal app data, including cleanup.

Use `plan-task` before implementation, agree on the plan, then use `implement-task`.
Run relevant Debug and Release tests sequentially; use `ENABLE_TESTABILITY=YES`
for Release unit tests as described in the README. Record exact results,
failures, and unverified behavior. Use `review-changes` after implementation and
address actionable findings before `prepare-pr` drafts publication scope and a PR
description. Committing, pushing, and creating a PR require separate explicit
authorization under `AGENTS.md`; never merge automatically.
