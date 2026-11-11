---
name: review-changes
description: Review a diff for concrete defects and missing acceptance criteria without editing files.
---

# Review changes

Read repository instructions, acceptance criteria, and the relevant diff and
surrounding code. If Git history is unavailable, inspect the supplied comparison
and state limits on the review scope.

Look for actionable correctness defects, regressions, unmet acceptance criteria,
and meaningful test gaps. Prioritize findings by impact; cite the file and line
with a concrete trigger and consequence. Avoid speculative issues and unrelated
style preferences.

Report findings first, followed by open questions and verification limits. If no
defects are found, say so without implying full verification. Do not edit files,
commit, push, create a PR, or merge.
