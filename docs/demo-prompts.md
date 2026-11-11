# Workshop prompts

Open `codex-community-starter` as the Codex project. Use these prompts verbatim,
one stage at a time. Completion is the exercise, not part of the baseline.
The [README](../README.md) covers setup and test commands.

## 1. Plan

```text
Use $plan-task to inspect tasks/complete-task.md, AGENTS.md, the current app,
tests, and staged, unstaged, and untracked changes. Propose a bounded plan for
completion toggling in both directions, distinct completed-task presentation,
the pending count, and persistence across restarts. Preserve existing tasks,
their IDs, titles, order, and unrelated completion flags. Include acceptance
checks for unreadable saved data and test storage isolation in Debug and Release.
Add no dependencies. Do not change application code yet. Surface material
ambiguity and wait for agreement on the plan. Do not stage, commit, push,
publish, or access Jira.
```

Read and resolve the plan before proceeding. The next prompt explicitly agrees
to the latest plan; send it only when that is your intent.

## 2. Implement

```text
I agree to the latest bounded plan. Use $implement-task to implement it against
tasks/complete-task.md. Preserve unrelated work and add no dependencies or
unrelated features. Add meaningful unit and UI tests for both toggle directions,
distinct completion presentation, pending count updates, preservation of existing
task fields, persistence across relaunch, and blocking mutations when saved data
is unreadable. Keep all tests isolated from normal app data, including cleanup.
Run relevant Debug and Release tests sequentially, using ENABLE_TESTABILITY=YES
for Release unit tests. Report actual checks, exact results, and anything
unverified. Do not stage, commit, push, publish, or access Jira.
```

## 3. Review

```text
Use $review-changes to review the actual source, tests, and staged, unstaged,
and untracked application changes against tasks/complete-task.md and the agreed
plan. Check both toggle directions, distinct completed-task presentation, the
pending count, preservation of existing IDs/titles/order/completion flags,
persistence across restarts, unreadable-data protection, and test isolation in
Debug and Release, including relaunch and cleanup. Read the actual tests and
verification evidence; do not treat an implementation report as proof. Report
actionable findings first with file locations, concrete reproduction steps,
and missing coverage. If none are found, say so and state verification limits.
Do not edit files or Git state, commit, push, publish, or access Jira.
```

If review finds defects, agree on a bounded correction and repeat implementation
and review before continuing.

## 4. Prepare a PR draft

```text
Use $prepare-pr to inspect Git boundaries, the current branch and intended base,
and staged, unstaged, and untracked files for the completed workshop exercise.
Propose publication scope containing only codex-community-starter. Exclude
unrelated projects, personal paths, credentials, authentication data, local
runtime configuration, Xcode user state, build products, test results,
presentations, and temporary logs. Report existing staged files without changing
the index. Draft a concise PR title and description covering resulting behavior,
acceptance criteria, actual verification commands and results, remaining limits,
and blockers. Do not invent a base branch or verification result. Do not choose
a license, stage, commit, push, create a PR, publish, merge, or access Jira.
```

PR preparation is a local draft. Committing, pushing, and creating a PR each
require separate explicit authorization. Jira is optional and requires separate
authorization for the intended access and any write.
