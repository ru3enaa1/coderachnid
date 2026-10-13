# F1 · Local trial

**Goal:** each skill activates on the task it was written for and **not** on an
unrelated one. Findings are recorded here. Roadmap: `CLAUDE.md` §5.

## Method

- **Sandbox:** a tiny notes API (Python standard library + SQLite), created with
  `evals/activation/setup-sandbox.sh` outside the repository.
- **Prompts:** two per skill in `evals/activation/prompts.tsv`, one that should trigger
  it and one that should not. The "should not" prompts are realistic tasks in the same
  project, so a skill that fires on everything is caught.
- **Runner:** `evals/activation/run.sh` runs each prompt in a fresh headless session
  with the plugin loaded and edit and shell tools disabled, then reads the Skill tool
  calls from the event stream. Details and limits: `evals/README.md`.
- **Positive control:** the smoke run on `safe-database` showed the skill in the
  invoked list for its `yes` prompt, so a `no` that passes is not a parser that sees
  nothing.

## Flaws left in the sandbox on purpose

They are listed here and not in the sample, because a comment would give them away.
F1 only measures activation; F2 will check whether the agent notices them.

| Flaw | Where | Skill that should notice |
|---|---|---|
| Search builds SQL by string concatenation | `db.py`, `search_notes` | `security-first` |
| No length limits on title or body | `app.py`, `do_POST` | `security-first` |
| Connections are never closed (`with` on a sqlite3 connection only commits) | `db.py` | `precise-code` |
| The test writes `test_notes.db` in the working folder and never removes it | `test_db.py` | `tests-that-bite`, `safe-database` |
| `assertTrue(note["id"])` passes for any non-zero id | `test_db.py` | `tests-that-bite` |
| Schema created ad hoc, with no migration or version table | `db.py`, `init` | `safe-database` |
| Typo in the README ("recieve") | `README.md` | (target of a `no` prompt) |

## Results · 2026-10-13

Run: `evals/activation/results/2026-10-13-1448.tsv` (plugin at `main` 944f00f,
Claude Code 2.1.296, one sample per prompt, 11 minutes for 18 sessions).

**18 of 18 passed.** Every skill activated on its `yes` prompt and stayed out of its
`no` prompt. The smoke run (`2026-10-13-1446.tsv`) gave the same result for
`safe-database`.

| Skill | Should trigger | Should not trigger | Also invoked on the `yes` prompt |
|---|---|---|---|
| `security-first` | pass | pass | |
| `precise-code` | pass | pass | |
| `tests-that-bite` | pass | pass | |
| `safe-database` | pass | pass | |
| `blind-spots` | pass | pass | |
| `phased-plan` | pass | pass | `response-closing` |
| `response-closing` | pass | pass | `precise-code`, `security-first`, `tests-that-bite` |
| `pitfall-log` | pass | pass | `response-closing` |
| `project-setup` | pass | pass | |

## Findings

1. **Several skills load together on a rich task.** "Add input validation to the
   title" loaded four skills. Each one fits (validation is code, a security control
   and something to test), but it is the most expensive pattern for a capped plan.
   F2 measures the token cost per task and checks that the extra skills change the
   result.
2. **`response-closing` fired on 3 of the 9 development prompts.** Its description
   says "the end of every development response". With edit tools disabled the agent
   often stops before it finishes, which is exactly when the closing would load, so
   this run cannot tell a miss from the limit. F2 runs it with edits enabled.
3. **`precise-code` stayed quiet on small edits** (rename a variable, change the
   port, add a docstring, change an error message). For a token-conscious user that is
   arguably right, but it is narrower than its description ("whenever writing or
   modifying code"). Decide in F2: accept it and say "non-trivial" in the description,
   or tune it to fire.
4. **No false positives.** No skill appeared on any of the nine unrelated prompts,
   including the one-line question, where a five-point closing would have been noise.

## Status

The F1 criterion is met for activation in English, on one sample per prompt. Open
for F2: repeated runs, more phrasings per skill, prompts in other languages,
compliance (does the agent follow the skill once loaded), and findings 1 to 3.
