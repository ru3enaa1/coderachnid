---
name: adr-guard
description: Use when the user asks whether a task, a change or a delivery needs an ADR or a deep review; when the user pastes an "adr-guard result" block from another session; before code is handed over to an organization, a client or another team; and when work changes authentication, permissions, money, personal data, a database schema or migration, a public API or security settings. Scans the task and the repository read-only and says, once and with its evidence, whether to run /coderachnid:adr-guard plan (ADRs with checkable clauses, before coding) or audit (an evidence-backed review of compliance, damage and security, after), with the complete command for a new session and what to bring back. Plan and audit run only when the user asks for them.
argument-hint: "[plan \"task\" | audit <ADR id> <base ref or diff file> [\"note\"]]"
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
| The user pasted a block that starts with `adr-guard result` | **The result came back**, below |
| Anything else: a question about it, or you loaded this skill yourself | **Triage only**, below |

**Never start a plan or an audit on your own initiative.** Both write files, run the whole
build and spend many tokens; the user decides when. Loaded on your own, you triage and
recommend the command, nothing more.

## Triage: the sixth sense

### Read, never change

- **Allowed:** the task as the user gave it; `git status`, `git log --oneline -20`,
  `git diff --stat`, `git merge-base`, `git rev-parse`; the ADR folder (`docs/adr/` or the
  organization's own); `docs/reviews/`; the project's rules; the files the task touches.
- **Not allowed:** builds, tests, migrations, installs, network calls, writing, moving or
  deleting files, git commands that change state. Triage leaves the repository as it was.

### Triggers: any one is enough

1. The code goes to someone else: an organization, a client, another team's codebase.
2. Authentication, authorization, sessions or roles.
3. Money: payments, balances, prices, invoices, transfers, interest.
4. Personal or sensitive data collected, stored, exported, shared or logged.
5. A database schema change, a data migration, or a fix on real data.
6. A contract other systems consume: public API, event, file format, shared library.
7. Security settings, secrets, new dependencies, infrastructure or deploy configuration.
8. Several files written mostly by AI agents, about to be merged or delivered.

**Not needed:** documentation or copy only · tests only · a refactor a passing suite shows
unchanged · a throwaway prototype · no trigger above · a head commit that already has an
audit in `docs/reviews/` and hasn't changed since.

### When to speak, and when to stay quiet

An alarm that rings at every step gets ignored, and the work turns into auditing instead
of building. So:

- **Certain or silent.** Say NEEDED only when a file, a line or the task's own words show
  the trigger. No "you might consider": what can't be shown isn't said.
- **Before coding** a risky task with no accepted ADR: recommend `plan`, once. If the user
  goes on without it, don't ask again; the recommendation at the end becomes "plan, then
  audit".
- **While you are still building it: silent.** Steps of a task you are still carrying
  out don't each get a recommendation.
- **When you hand the change back** (its code is written and the reply returns it to the
  user to test, review or commit): the full block below, once. Don't hold it until the
  tests pass or promise it for later: a first version deferred it, and the user had to
  come back and ask for the command. The closing already says to run the tests first.
- **One audit per ADR or feature**, covering everything since its base. Never one per file
  or per sub-step.
- **Not again for later steps of the same change**, unless code under a new trigger was
  added. Once more only when the user says the code is going out (merge, release,
  delivery) and no result block has come back: the block again, with its scope
  refreshed. If the user declined it, one line instead of the block.
- **Asked directly, always answer**: the block, or `adr-guard · NOT NEEDED · <reason>` in
  one line. Unasked and not needed: nothing.
- About to clear the conversation with an audit pending? Put the block in the handoff's
  next step.

### The recommendation block

```text
adr-guard · NEEDED · audit
Why: <each trigger, with the file and line, or the task's words, that show it>
Scope: ADR-<id> · <base commit>..<head commit> · <n> files
Run in a new session: /coderachnid:adr-guard audit <id> <base commit>
Bring back: the "adr-guard result" block that session prints at the end
```

- **The first line says which:** `audit` (the code exists and an accepted ADR covers it),
  `plan` (no ADR, code not written) or `plan, then audit` (code written, no ADR: the plan
  writes a retroactive one). For the last, number both commands under *Run*.
- **The command is complete.** Ids and commits come from what was read (the base is the
  commit before this work: the baseline file, or `git merge-base` with the main branch),
  never a placeholder. A value that can't be read (no git yet, no shell) doesn't cancel
  the block: write what is known and, in its place, the one step that produces it.
- **The new session knows nothing of this conversation.** For `plan`, the quoted task
  carries the acceptance criteria and the paths involved. For `audit`, an optional last
  quoted note says what to look at hardest; it never narrows what the audit covers.
- **Keys stay in English, exactly as above:** the blocks are the protocol between two
  sessions. Values are written in the user's language.

## The result came back

The other session ends with a block that starts with `adr-guard result`; the user pastes
it here, and the thread continues:

1. **Open the report it names.** The block is the summary; the report is the evidence. No
   report at that path: say so and stop.
2. **Act on the verdict.** APPROVE: nothing to fix, say the change is cleared. APPROVE
   WITH CONDITIONS: do the conditions that are yours, list the human's. INCONCLUSIVE: run
   what the report lists as not verified, or ask the user to, and report the outcome.
   BLOCK: fix blockers first, then majors, in the report's order, each with a failing test
   before the fix, inside the ADR's scope fence.
3. **Never edit the ADR or the report to make a finding go away.** Disagree with a
   finding? Show the user the evidence; they decide, and an amendment goes through `plan`.
4. **Re-audit only when it matters:** after fixing a blocker, or changing code under a
   critical clause, give the block again with the same base. Minor fixes need none.

## What the modes produce

- **plan:** `docs/adr/NNNN-<title>.md` (*proposed*, with decision clauses, a check per
  clause, a scope fence, rollback) and a baseline in `docs/reviews/`.
- **audit:** `docs/reviews/ADR-NNNN-audit-<date>.md` and a verdict: APPROVE, APPROVE WITH
  CONDITIONS, INCONCLUSIVE (a critical check could not run) or BLOCK.
- **Both end with the `adr-guard result` block**, ready to paste into the session that
  asked. In an organization's repository, ask before committing `docs/reviews/`.

## Rules for both modes

- **Evidence or it didn't happen.** Every claim, a pass included, names a file and line,
  a command with its exit code, or a test.
- **The ADR is the contract.** A deviation becomes a proposed amendment for the human to
  decide; it is never accepted silently.
- **Nothing leaves the machine.** No code to external services; nothing posted to a pull
  request, ticket or chat unless the user asks.
- **Say what it can't do.** A review raises confidence but can't prove bugs are absent
  (Dijkstra, 1970). It doesn't replace the organization's own review or sign-off.

> **Measured on a fictional service** (2026-11-26): triage with the complete block 4 of
> 4, quiet 2 of 2; the block given once and never repeated, 6 of 6 real sessions; audits
> found every planted defect and ended with the result block, 8 of 8; a pasted result
> acted on from its report, 2 of 2. From published practice (Nygard 2011; Ford, Parsons
> and Kua 2017) and field rules. Record what fails on real deliveries in `pitfall-log`.

References: `references/plan.md` (plan mode, ADR format, baseline) ·
`references/audit.md` (audit mode, verdict rules) · `references/audit-lenses.md` (the six
lenses) · `references/review-report.md` (report, severities, the result block).
