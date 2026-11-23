# adr-guard · the audit report

File: `docs/reviews/ADR-NNNN-audit-<YYYY-MM-DD>.md`. Written for two readers: the person
who receives the code reads the summary; the person who fixes it reads the rest.

## Severity

| Severity | Means | Examples |
|---|---|---|
| BLOCKER | Can't be delivered as is | data loss or corruption; a security hole; a VIOLATED clause; a regression against the baseline; a broken build |
| MAJOR | Must be fixed or accepted by name before delivery | a clause whose check doesn't exist or doesn't bite; an unhandled failure path; the scope fence crossed without a reason |
| MINOR | Should be fixed | naming, small duplication, a missing log line |
| NOTE | Worth knowing | an observation with no action required |

A finding is **confirmed** when a probe, a command or the code itself proves it, and
**suspected** otherwise, with what would confirm it. Severity applies to both; the
summary separates them.

## Template

```markdown
# Audit · ADR-NNNN · <title>

- **Date:** YYYY-MM-DD · **Base:** <commit> · **Head:** <commit> · **Auditor:** adr-guard (fresh session)
- **Verdict:** APPROVE | APPROVE WITH CONDITIONS | INCONCLUSIVE | BLOCK

## Summary (one screen)
- <the verdict in one sentence, and the reason>
- Blockers: <n> · Major: <n> · Minor: <n> · Notes: <n> · Suspected: <n>
- Clauses: <n> MET · <n> PARTLY · <n> VIOLATED · <n> NOT VERIFIABLE
- Regressions against the baseline: <n>
- Not verified: <what, in a few words>
- Conditions or next step: <who does what>

## Scope
Files and hunks reviewed (numbered); uncommitted changes and how they were treated; files
outside the scope fence.

## Compliance matrix
| Clause | Rule | Check run | Result | Evidence |
|---|---|---|---|---|

## Findings
| Id | Severity | Confirmed / suspected | Lens | Location | What is wrong | Evidence | Clause | Suggested fix |
|---|---|---|---|---|---|---|---|---|

## Regressions against the baseline
| Test or check | Baseline | Now | Command and exit code |
|---|---|---|---|

## Positive control of the review
What was planted, in which worktree, and which check or lens caught it (or that none did).

## Coverage ledger
| Hunk | Compliance | Correctness | Security | Damage | Direction | Operations |
|---|---|---|---|---|---|---|
| 1 · path:lines | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

## Not verified
Each item with the reason (no shell, a missing service, no credentials, too big) and
what would verify it.

## Proposed amendments
Deviations that look right, as proposed ADR changes for the human to decide.
```

## Rules for the report

- **Every row has evidence.** A finding without location and evidence is removed, or
  turned into a suspected one with what would confirm it.
- **Numbers in the summary match the tables.** Count them from the tables, after writing
  them.
- **No personal data or secrets** in the report, even when a finding is about them:
  name the file and line, not the value.
- **Plain words.** The summary is read by someone who didn't write the code and may not
  read code at all.
