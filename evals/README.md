# Evals

Checks that the skills do their job in a real Claude Code session. Guards prove the
files are well formed; evals prove the agent actually uses them.

## Eval suite (F2): `claude plugin eval`

From F2 on, evals use Claude Code's built-in runner. Cases live in `evals/cases/`, one
directory per case with a `case.yaml` and a `fixture.sh` that copies the sample project
from `activation/sandbox/` into the run's empty workspace.

| Group | What it checks | Graders |
|---|---|---|
| `cases/activation/<skill>-fires-<lang>` | The skill activates on another phrasing, in English and in Spanish | `tool_used: Skill` |
| `cases/activation/<skill>-quiet-es` | The skill stays out of an unrelated request in Spanish | `tool_used: Skill`, `min: 0`, `max: 0` |
| `cases/compliance/*` | Once loaded, the skill changes the result, measured against a no-plugin baseline | `regex` on files or the reply, `llm` rubric, plus a skill indicator |

```sh
claude plugin eval . --tag activation --ablation none --scaffold --trust-plugin --no-publish -j 2
claude plugin eval . --tag compliance --scaffold --trust-plugin --no-publish --allow-tools Edit Write
```

- `--scaffold` runs the case's `fixture.sh`. The scripts are ours and only copy files.
- Activation runs one arm (`--ablation none`): a "skill fired" check means nothing
  without the plugin. Compliance runs both arms, and `Δ` is what the plugin added.
- Grant `Edit` and `Write` for compliance cases. Never grant `Bash` on native Windows:
  there is no sandbox backend, so such runs are refused.
- The Spanish prompts are test data: they check activation for non-English users.
- Raw output goes to `evals/results/` (git-ignored). Summaries go to `docs/F2-EVALUATION.md`.
- Every run is a real session; the CLI prints its cost. Bound a run with `--max-cost-usd`.

### Traps found while building the suite

- **Positive-control every grader** against a bad and a fixed version before trusting
  it. The first SQL-concatenation regex also matched the safe fix and failed every run.
- **A batch can hit the plan's usage limit midway.** Later runs end with a "session
  limit" error and score 0, which looks like a regression. Read each run's error, then
  rerun only those cases after the reset.
- **Repeating `--case` keeps only the last one.** Use a glob or separate runs.
- **A loaded skill's text is part of the trace.** A `regex` on `target: trace` for
  "backup" passes in every with-plugin run, because `safe-database` says "backup".
  Match only what the agent wrote: `'"name":"(?:Edit|Write)"[^\n]*<pattern>'`.
- **Write grader patterns with a file tool, never a shell heredoc.** On Windows the
  heredoc turned `[\\/]` into `[\/]`, a class that can never match a Windows path.
- **Measure in isolation.** The F1 runner used the maintainer's own environment and
  reported 18 of 18; the isolated suite with more phrasings found four weak skills.
- `--keep-temp` keeps a run's workspace and trace for debugging. Read only `out/`,
  never run git or tools inside it, and delete it afterwards.

## Activation (F1, superseded by the suite above)

Does each skill activate on the task it was written for, and stay quiet on an unrelated
one? `activation/prompts.tsv` holds two prompts per skill: one that should trigger it
(`yes`) and one that should not (`no`).

```sh
bash evals/activation/setup-sandbox.sh ../coderachnid-sandbox     # once
CLAUDE_BIN="<path to claude>" bash evals/activation/run.sh ../coderachnid-sandbox
CLAUDE_BIN="<path to claude>" bash evals/activation/run.sh ../coderachnid-sandbox safe-database
```

- Each prompt runs in a fresh headless session (`claude -p`) with the plugin loaded and
  edit and shell tools disabled. A skill is invoked before any edit, so activation is
  still visible, and nothing in the sandbox changes.
- A prompt passes when the expected skill appears (or, for `no`, does not appear) among
  the Skill tool calls in the session's event stream.
- Results land in `activation/results/<timestamp>.tsv`. Commit them: they are the
  record of how activation changed as descriptions were tuned.
- Every prompt is a real session on your plan. One full run is 18 sessions.

### Limits

- One sample per prompt. A model is not deterministic, so a single pass or fail is a
  signal, not a measurement. F2 repeats each prompt and adds more phrasings.
- With edit tools disabled, a skill the agent would invoke *after* editing (late in a
  long task) can be missed. `response-closing` is the most exposed.
- English prompts only for now. Prompts in other languages are an F2 item.
