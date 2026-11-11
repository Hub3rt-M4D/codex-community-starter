---
name: prepare-pr
description: Inspect publication scope and draft a PR description using actual verification evidence.
---

# Prepare a PR

Read repository instructions and agreed task scope. Inspect the intended base,
branch, staged and unstaged changes, and untracked files when Git is available.
Identify unrelated work and secrets before selecting publication scope. If Git
is unavailable, draft from available files and state that publication scope
could not be verified; do not initialize Git.

Draft a concise title and description covering the problem, resulting behavior,
and actual verification evidence. Name checks and outcomes, including failures,
checks not run, and remaining limitations. Never invent a passing result.

Show the proposed scope and draft before requesting missing authorization.
Commit, push, or create a PR only with explicit user authorization for that
action and scope; one authorization does not imply the others. Exclude unrelated
changes and never commit credentials. Stop on publication failures and report
them before changing scope or destination. Never merge automatically.
