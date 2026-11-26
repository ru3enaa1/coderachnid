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

## The result block

The last thing an audit or a plan prints, fenced so it can be copied whole into the
session that asked for it. It is the thread between the two conversations: the other
session reads it, opens the report and continues (see `../SKILL.md`, "The result came
back"). Keys in English, exactly as below; values in the user's language.

After an audit:

```text
adr-guard result
Mode: audit · ADR-0007 · base 3f2a91c → head 8d04e7b · 2026-11-26
Verdict: APPROVE WITH CONDITIONS
Report: docs/reviews/ADR-0007-audit-2026-11-26.md
Clauses: 5 MET · 0 PARTLY · 0 VIOLATED · 1 NOT VERIFIABLE
Findings: 0 blocker · 2 major · 1 minor · 0 note (1 suspected)
Fix first:
1. [MAJOR] src/orders/refund.py:41 · the refund is not recorded when the gateway times out → record it as pending inside the same transaction
2. [MAJOR] tests/test_refund.py:88 · the D4 test can't fail (it asserts the mock) → assert the stored row
Conditions: fix 1 and 2 before delivery (implementer); confirm the 30-day limit with the client (owner)
Not verified: D6 response time, no load tool in this session
Next: fix 1 and 2 with a failing test first; no re-audit needed unless D2 code changes
```

After a plan:

```text
adr-guard result
Mode: plan · ADR-0008 (proposed) · base 8d04e7b · 2026-11-26
ADR: docs/adr/0008-refunds-through-one-service.md
Baseline: docs/reviews/ADR-0008-baseline.md
Clauses: 6 (4 critical) · Open questions: 2
Next: accept the ADR or answer its open questions; implement with the clauses as the brief; then, in a new session: /coderachnid:adr-guard audit 0008 8d04e7b
```

- **Every line is filled from the report**, after the report is written. Paths are
  relative to the repository, with forward slashes, so they work pasted anywhere.
- **"Fix first" lists blockers, then majors, at most seven**, each as `[SEVERITY]
  path:line · what is wrong → the fix`. More than seven: the first seven, then "and N more
  in the report". None: `Fix first: nothing`.
- **"Next" is one action for the session that receives the block**, with the complete
  re-audit command when a re-audit is needed, and "no re-audit needed" when it isn't.
- **No secrets and no personal data** in the block: it travels between conversations.

## Rules for the report

- **Every row has evidence.** A finding without location and evidence is removed, or
  turned into a suspected one with what would confirm it.
- **Numbers in the summary match the tables.** Count them from the tables, after writing
  them.
- **No personal data or secrets** in the report, even when a finding is about them:
  name the file and line, not the value.
- **Plain words.** The summary is read by someone who didn't write the code and may not
  read code at all.
