---
name: pitfall-log
description: Use while debugging anything that behaved unexpectedly, and right after the fix: a flaky or order-dependent test, a failure that only happens on another machine, time zone or environment, a test that passed for the wrong reason, a tool or framework surprise, or a bug the user says they already tried to fix. Records the lesson as a dated pitfall with symptom, cause, rule and the check that now catches it, so the same mistake is never paid for twice.
---

# Pitfall log

Every mistake that cost real time becomes a rule, and a check, the same day. This is how
the sieve gets finer over time: the other skills in this plugin started as entries in a
log like this one.

## When to record

- A build, test or tool failed in a way that wasn't obvious from the error.
- A test passed while the feature was broken (or failed while it worked).
- A fix needed more than one attempt.
- Behavior differed between environments (test vs. real server, one OS vs. another,
  one library version vs. another).
- A trap was anticipated but not yet seen. Record it as **anticipated** and confirm it
  when it happens.

## Format

One entry per pitfall, in the project rules file (`CLAUDE.md`, "Pitfalls" section),
grouped by area (environment, build, framework, CSS, tests, database):

```markdown
- **<The rule, in bold, as an instruction>** (<symptom you saw>): <why it happens>.
  <The check or test that now catches it>. Confirmed YYYY-MM-DD.
```

Example:

```markdown
- **Never kill a process by name; stop it by PID or port** (two other apps died with
  it): `taskkill /IM java.exe` matches every JVM. `stop.ps1` resolves the PID from the
  port. Confirmed 2026-10-01.
```

## Rules

- **Lead with the rule, not the story.** The reader needs the instruction first.
- **Include the symptom**, so the next person recognizes the trap when they hit it.
- **Every pitfall points to a check**: a test, a script, an assertion or a command.
  A lesson with no check will be forgotten.
- **Date it.** Mark anticipated ones as such and confirm them when they happen.
- **Prune.** A pitfall that turns out to be wrong is deleted. A stale one is updated.
- **Generalize before sharing.** Remove names, paths, customers and anything private.
  What remains is the rule and the reason.

## Promote it

When a pitfall applies beyond one project, contribute it to coderachnid. Generalize it,
add it to the right skill or `references/` file, and open a pull request (see
`CONTRIBUTING.md`).
