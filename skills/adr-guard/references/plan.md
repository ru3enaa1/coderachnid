# adr-guard · plan mode

Before the code is written: turn the task into decisions the code must follow, each
with a check that can prove it later, and record how the system behaves today. The ADR
written here is the contract the audit checks.

## 1. Read before writing

- **The task**, word for word: the ticket, the message, the acceptance criteria. If it
  links to something you can't open, ask for the text.
- **The organization's decisions:** existing ADRs (`docs/adr/` or their own folder),
  architecture notes, `CONTRIBUTING`, `CODEOWNERS`, lint and CI configuration. **Their
  ADR format wins over this one**: add the sections below that theirs lacks (clauses,
  checks, scope fence, baseline) without dropping theirs.
- **The code area** the task touches, its tests, and who calls it.
- An accepted ADR that already decides part of this is cited, not rewritten. If the task
  contradicts one, stop and say so: that is a decision for the human.

## 2. Ask without blocking

- **Two things stop the plan:** the task contradicts an accepted ADR, or there is nothing
  to decide from (no acceptance criteria, and none can be inferred from the task or the
  code). Say which, propose the options, and wait.
- **Everything else is written, not waited for.** For each open question (a limit, a
  volume, a format), write your recommended answer into the clause or section it
  affects, marked **ASSUMPTION**, and list the questions at the end of the ADR under
  *Open questions*. The ADR is only *proposed*: the human corrects or accepts it, and a
  question left in writing is not lost when the conversation ends. A first eval run that
  asked and waited instead produced no ADR at all.
- Never ask what the code or the documents already answer.

## 3. Write the ADR

One ADR per decision. A small task usually needs one; a task that makes two independent
decisions (a data model and an API shape) gets two. File: `docs/adr/NNNN-<title>.md`,
next free number, status **proposed**.

```markdown
# ADR-NNNN · <decision, as a short sentence>

- **Date:** YYYY-MM-DD · **Status:** proposed · **Task:** <ticket id or one line>
- **Retroactive:** no (yes when written after the code existed; say so)

## Context
<The problem, the forces, the constraints. Why this needs deciding now.>

## Options considered
1. **<Option A>:** pros / cons.
2. **<Option B>:** pros / cons.

## Decision
<What was chosen, in prose.>

## Decision clauses

| Id | Rule the code must follow | Check that proves it | Critical |
|---|---|---|---|
| D1 | <one rule, testable, no adjectives> | <test name, command, architecture rule or search> | yes / no |

## Scope fence
- **May change:** <paths or modules>
- **Must not change:** <public signatures, schema, contracts, configuration, other modules>
- **Out of scope:** <what someone might expect but this task doesn't do>

## Constraints
<Security, personal data, performance with numbers, compatibility, regulation.>

## Damage to watch
<Callers, data, other teams, clients: what breaks first if this goes wrong.>

## Rollback
<How the change is undone, and what can't be undone (data written, messages sent).>

## Consequences
<What becomes easier, what becomes harder or forbidden.>

## Open questions
<Each question, the ASSUMPTION written above for it, and who answers it.>
```

### Writing the clauses

- **One rule per clause**, stated so that a reader can say "met" or "not met" without
  asking you. "Transfers use integer cents end to end" is a clause; "money is handled
  safely" is not.
- **Every clause has a check**, and the check is objective: a test that fails if the
  rule is broken, an architecture rule (a forbidden dependency), a command, a search with
  the exact pattern. Ford, Parsons and Kua call this a fitness function: "an objective
  integrity assessment" of a characteristic the system must keep. A clause without a
  check is not finished.
- **Write the check as it will be run**, with the command or the test name, so the audit
  runs it instead of interpreting it.
- **Mark critical clauses:** security, personal data, money, contracts, data integrity.
  A critical clause the audit can't verify blocks the delivery.
- **Cover what the task must not do** as clauses too: "no new dependency", "the public
  signature of `get_balance` stays the same". Damage comes mostly from what nobody said.

## 4. Record the baseline

File: `docs/reviews/ADR-NNNN-baseline.md`. Run the commands; never copy results from
memory or from what someone said earlier.

- Base commit (`git rev-parse HEAD`), branch, date, uncommitted changes (`git status`).
- The full build and the full test suite: command, **exit code**, counts, and the list
  of tests that already fail, by name.
- Linters and static analysis the project uses: command, exit code, number of warnings.
- How to start the application, and whether it started.
- If something can't run (no shell, missing service, no credentials), write what and
  why. The audit will then report regressions it can't separate from old failures.

## 5. Hand over

- Show the ADR and the baseline, and ask the human to accept the ADR. On acceptance,
  change the status to **accepted** with the date. Until then, implementation waits.
- **Give the clauses to whoever implements.** When agents write the code, paste the
  decision clauses and the scope fence into their instructions: they are the brief.
- Close with the command for later, in a fresh session, with the base filled in:
  `/coderachnid:adr-guard audit NNNN <base commit>`.
