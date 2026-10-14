# F2 · Evaluation

**Goal:** measure each skill and tune the descriptions. Roadmap: `CLAUDE.md` §5.
Tooling: `claude plugin eval` (Claude Code 2.1.296). Suite and commands:
`evals/README.md`.

## What was measured

- **Activation:** 27 cases. Per skill, two prompts that should trigger it (another
  English phrasing and a Spanish one, 2 runs each) and one Spanish prompt that should
  not (1 run). Read-only tools, one arm.
- **Compliance:** 4 cases with `Edit` and `Write` granted, 2 runs per arm, with and
  without the plugin, so `Δ` shows what the plugin added.
- Every case copies the sample notes project from `evals/activation/sandbox/`.

## Activation

First run (descriptions from F0), then the tuned ones. Latest valid result per case:

| Skill | Fires (EN) | Fires (ES) | Stays quiet (ES) | Change |
|---|---|---|---|---|
| `security-first` | 0/2 → **2/2** | 0/2 → 0/2 | 1/1 | Tuned: concrete triggers (endpoint, upload, auth, personal data) |
| `precise-code` | 2/2 | 2/2 | 1/1 | Tuning tried and reverted: "beyond a trivial edit" dropped it to 2/4 |
| `tests-that-bite` | 2/2 | 2/2 | 1/1 | |
| `safe-database` | 2/2 | 2/2 | 1/1 | |
| `blind-spots` | 0/2 → **2/2** | 2/2 → 2/2 | 1/1 | Tuned: "done, ready, safe to ship, merge or release" |
| `phased-plan` | 2/2 | 2/2 | 1/1 | |
| `response-closing` | 0/2 → 0/2 | 0/2 → 0/2 | 1/1 | Tuned wording loads it about 1 run in 3 with edits; see D-009 |
| `pitfall-log` | 0/2 → **2/2** | 0/2 → **2/2** | 1/1 | Tuned: user-reported failures, "while debugging" |
| `project-setup` | 2/2 | 2/2 | 1/1 | |

**No false positives** in any run, before or after tuning, including after the
descriptions were widened.

## Compliance: with and without the plugin

| Case | With | Without | Δ | Cost with plugin |
|---|---|---|---|---|
| Closing after an edit | 0.00 | 0.00 | 0 | +17% |
| Search without SQL injection | 1.00 | 1.00 | 0 | +65% |
| Tests that can fail | 1.00 | 1.00 | 0 | +44% |
| Trivial rename | 1.00 | 1.00 | 0 | +17% |

**On these four tasks the base model already did the right thing, and the plugin cost
34% more on average.** It fixed the concatenated SQL, wrote tests with no residue and
concrete assertions, and renamed cleanly, with or without the plugin.

## Findings

1. **The plugin's value is not demonstrated yet.** Small, well-specified tasks don't
   need it, and loading skills costs tokens. That is the opposite of the promise for a
   capped plan unless the plugin wins on the tasks where the base model fails. Next:
   compliance cases where the baseline is expected to fail (multi-step features,
   schema changes that need a backup and a migration, "done" claims with no evidence),
   and a look at trimming what each skill loads.
2. **Always-on behavior can't depend on activation** (D-009). `response-closing`
   loads on some development replies, not all, whatever its wording, because skills are
   chosen per task. The five-point closing belongs in the project rules file, which
   `project-setup` already writes. The skill keeps the format.
3. **Concrete triggers beat abstract ones.** "At the start of every phase, feature or
   endpoint" read as a planning moment. Naming what the code touches (endpoint, upload,
   auth, personal data) fixed English activation. The Spanish "edit endpoint" prompt
   still misses: open.
4. **Narrowing a description can cost activation where it matters.** `precise-code`
   already skips trivial edits (the rename case), so F1 finding 3 needs no change.
5. **F1's 18 of 18 was optimistic.** It ran with one sample per prompt in the
   maintainer's own environment. The isolated suite with more phrasings found four
   weak skills.

## Pitfalls hit while evaluating

- **A grader can fail the correct answer.** The first "no concatenated SQL" regex also
  matched the safe fix (`"%" + q + "%"` passed as a parameter) and failed every run.
  Each grader pattern is now checked against the bad and the fixed code before use.
- **A batch can hit the plan's usage limit midway.** Later runs end with "You've hit
  your session limit", score 0 and look like a regression. Check each run's error
  before trusting a score, and rerun only the affected cases after the reset.
- **Repeating `--case` keeps only the last one.** Use a glob (`'act-security-first-*'`)
  or separate runs.

## Cost

About 15 USD at API prices across all runs (activation, compliance, diagnostics and
reruns). On a subscription it comes out of the plan's usage window, and this phase hit
the session limit once.

## F2b · Value on harder tasks

Finding 1 asked for tasks where the base model is expected to fail. Four cases, 2 runs
per arm, with `Edit` and `Write` (`evals/cases/value/`). Every grader pattern was first
checked against the agent's own edit and against a decoy (a loaded skill's text is in
the trace too).

| Case | With | Without | Δ | Cost with plugin |
|---|---|---|---|---|
| Import notes from JSON: size or count limit, per-item validation | **1.00** | 0.00 | **+1.00** | +107% |
| Add a column to a database that already holds data: real `ALTER TABLE` and a backup | **1.00** | 0.50 | **+0.50** | +71% |
| Wildcard bug in search: regression test written (first run; see tuning below) | **0.67** | 0.33 | **+0.33** | +69% |
| Closing with the rule in the project rules file | 1.00 | 1.00 | 0 | +62% |

- **Import:** without the plugin the endpoint checked types but read the whole body
  with no size limit. With it, every run added a byte limit answered with 413, plus a
  test for it. Checked in the code, not only by the judge (3 of 3 votes in every run).
- **Schema change:** both arms altered the existing table; only the plugin arm backed
  up the database first.
- **Wildcard bug:** both arms escaped `%` and `_`; only the plugin arm added a
  regression test. Neither wrote the test before the fix, and `tests-that-bite` did not
  load: "fixing a bug" in its description was not enough. Open.
- **Closing:** with the line in the rules file, all four runs closed with the five
  points, with or without the plugin. That settles F1 finding 2 and confirms D-009.

**Reading:** on small, well-specified tasks the plugin adds cost and nothing else. On
tasks with a hidden trap (untrusted input, existing data, a regression) it adds the
safeguard the base model skipped, at roughly 70 to 100% more tokens for that task. For
a capped plan the trade is the cost of finding the same gap later, in another session.
That later cost was not measured here.

## Tuning after F2b (2026-10-13)

| Change | Measured on | Result |
|---|---|---|
| `security-first`: "any endpoint or route (even one that only edits a field)" | Spanish edit-endpoint prompt, 4 runs; Spanish "should not" prompt, 4 runs | **4/4** fires (was 2/4 across earlier runs), 4/4 quiet. An English twin of the prompt fired 2/2 before the change, so language cost some reliability but was not a block |
| `tests-that-bite`: leads with "a bug is reported or fixed (failing test first)" | Wildcard bug, with and without the plugin; its activation cases | With **1.00** (test written before the fix in both runs), without 0.50: Δ **+0.50**. Activation 5/5, no false positive |

The red-first grader first checked only `Edit` and failed every run that created a new
test file with `Write`. It now accepts either, and was checked against five traces
(Write then fix, Edit then fix, fix then test, fix only, skill text) before use.

## Status

The F2 criterion is met: every skill was measured, and four descriptions were tuned on
evidence (one tuning reverted). F2b showed the value on harder tasks and made the
closing reliable through the rules file, and the last two activation gaps were
closed. Open: trimming what each skill loads, and more runs on the cases measured
with two.
