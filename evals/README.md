# Evals

Checks that the skills do their job in a real Claude Code session. Guards prove the
files are well formed; evals prove the agent actually uses them.

## Activation (F1)

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
