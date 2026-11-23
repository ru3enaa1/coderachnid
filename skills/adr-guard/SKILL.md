---
name: adr-guard
description: Use when the user asks whether a task, a change or a delivery needs an ADR or a deep review; before code is handed over to an organization, a client or another team; and when work changes authentication, permissions, money, personal data, a database schema or migration, a public API or security settings. Scans the task and the repository read-only and says in a few lines whether to run /coderachnid:adr-guard plan (ADRs with checkable clauses, before coding) or audit (an evidence-backed review of compliance, damage and security, after), with the exact command. Plan and audit run only when the user asks for them.
argument-hint: "[plan \"task\" | audit [ADR ids] [base ref or diff file]]"
arguments: [mode, subject, base]
---

# ADR guard

Decide before, audit after. For changes where a mistake is expensive: code delivered to an
organization or a client, code written mostly by AI agents, an MVP feature that handles
money, identity or personal data. The audit spends tokens on purpose; what it must never
do is leave a gap.

Requested: mode `$mode` · subject `$subject` · base `$base`.

## Which mode runs

| How it started | What runs |
|---|---|
| The user typed `/coderachnid:adr-guard plan "…"` or asked in words to plan the ADRs | **Plan:** read `references/plan.md` and follow it whole |
| The user typed `/coderachnid:adr-guard audit …` or asked in words to run the audit | **Audit:** read `references/audit.md` and follow it whole |
| Anything else: a question about it, or you loaded this skill yourself | **Triage only**, below |

**Never start a plan or an audit on your own initiative.** Both write files, run the whole
build and spend many tokens; the user decides when. Loaded on your own, you triage and
recommend the command, nothing more.

## Triage: the sixth sense

Asked "does this task need it?", or doing work that matches a trigger: scan, decide, answer
in the format below. No deliberation beyond it.

### Read, never change

- **Allowed:** the task as the user gave it (ticket text, message); `git status`;
  `git log --oneline -20`; `git diff --stat` against the base; the ADR folder
  (`docs/adr/` or the organization's own); `docs/reviews/`; the project's rules
  (`CLAUDE.md`, `CONTRIBUTING`, `CODEOWNERS`); the files the task touches.
- **Not allowed:** builds, tests, migrations, installs, network calls, writing, moving or
  deleting files, git commands that change state (checkout, stash, commit, reset, pull).
  Triage leaves the repository exactly as it found it.

### Triggers: any one is enough

1. The code goes to someone else: an organization, a client, another team's codebase.
2. Authentication, authorization, sessions or roles.
3. Money: payments, balances, prices, invoices, transfers, interest.
4. Personal or sensitive data collected, stored, exported, shared or logged.
5. A database schema change, a data migration, or a fix on real data.
6. A contract other systems consume: public API, event, file format, shared library.
7. Security settings, secrets, new dependencies, infrastructure or deploy configuration.
8. Several files written mostly by AI agents, about to be merged or delivered.

### Not needed

Documentation or copy only · tests only · a refactor a passing test suite shows
unchanged · a throwaway prototype · a change with no trigger above · code whose head
commit already has an audit in `docs/reviews/` and hasn't changed since.

### Which mode

- **plan:** no accepted ADR covers the change and the code isn't written yet.
- **audit:** the code exists and an accepted ADR covers it.
- **plan, then audit:** the code exists and no ADR covers it. The plan then writes a
  retroactive ADR, marked as such, from the task, so the audit has a contract to check.

### Answer, in this format

```text
adr-guard: NEEDED: audit | NEEDED: plan | NEEDED: plan, then audit | NOT NEEDED
Why: <each trigger matched, with the file, path or task line that shows it>
Run: /coderachnid:adr-guard <the exact command, arguments filled from what you read>
Cost: <heavy for audit (whole build, tests, several review passes); moderate for plan>; in a fresh session
```

Translate the labels to the user's language. If something can't be read (no git, no ADR
folder), say which and decide on what was read. NOT NEEDED takes one line with the reason.

### In the closing

When the work of the conversation matched a trigger and no audit of it is recorded, the
closing's **recommended implementation** names the exact command, in one line. When it
isn't needed, the closing says nothing about it.

## What the modes produce

- **plan:** `docs/adr/NNNN-<title>.md`, status *proposed*, with decision clauses D1…Dn,
  one objective check per clause, a scope fence, constraints, damage to watch and a
  rollback path; plus a baseline (`docs/reviews/ADR-NNNN-baseline.md`) that lets the
  audit tell a new failure from an old one.
- **audit:** `docs/reviews/ADR-NNNN-audit-<date>.md` with a one-screen summary, the
  compliance matrix, findings with evidence, regressions against the baseline, the
  coverage ledger, what could not be verified and why, and the verdict: APPROVE,
  APPROVE WITH CONDITIONS, INCONCLUSIVE (a critical check could not run) or BLOCK. The
  final reply repeats the summary.
- In an organization's repository, **ask before committing** anything under
  `docs/reviews/`: a report describes weaknesses.

## Rules for both modes

- **Evidence or it didn't happen.** Every claim, a pass included, names a file and line,
  a command with its exit code, or a test.
- **The ADR is the contract.** A deviation becomes a proposed amendment for the human to
  decide; it is never accepted silently.
- **Nothing leaves the machine.** Code is not sent to external services; nothing is posted
  to a pull request, ticket or chat unless the user asks.
- **Say what it can't do.** A review raises confidence but can't prove that bugs are absent
  (Dijkstra, 1970). It does not replace the organization's own review, security testing or
  compliance sign-off.

> **Measured on a fictional service** (2026-11-23): the triage fired and named the
> command 4 of 4 times and stayed quiet 2 of 2; the audit found every planted defect
> (compliance, security, damage) and never blocked the clean change, 8 of 8; the plan
> wrote a checkable ADR 2 of 2. Built from published practice (ADRs, Nygard 2011;
> fitness functions, Ford, Parsons and Kua 2017) and this plugin's field rules. Not yet
> used on a real delivery: record what fails in `pitfall-log`.

## References

- `references/plan.md`: the plan mode, the ADR format with checkable clauses, the baseline.
- `references/audit.md`: the audit mode, step by step, with the verdict rules.
- `references/audit-lenses.md`: the six lenses and what each one runs and reads.
- `references/review-report.md`: the report template, severities and coverage ledger.
