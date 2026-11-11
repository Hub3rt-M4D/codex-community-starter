---
name: implement-task
description: Implement an agreed plan, add meaningful tests, and run relevant verification checks.
---

# Implement a task

Read repository instructions and the agreed plan. If no bounded plan is agreed,
propose one before changing application code. Inspect existing changes and
preserve unrelated work. Clarify material scope changes before proceeding.

Implement the behavior and add or update meaningful tests where appropriate.
Use existing test targets and run relevant checks for the affected behavior.
Inspect the final diff for accidental changes and exposed secrets.

Report what changed, the actual commands or checks run and their results,
including failures and unverified behavior. Distinguish tool limitations from
passing checks. Commit, push, or create a PR only with explicit authorization
for each action; never merge automatically.
