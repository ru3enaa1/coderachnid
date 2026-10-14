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

## Status

The F2 criterion is met: every skill was measured, and four descriptions were tuned on
evidence (one tuning reverted). Open: the value of the plugin on harder tasks (finding
1), Spanish activation of `security-first`, and repeating the tuned cases with more
runs.
