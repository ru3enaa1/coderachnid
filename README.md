# coderachnid

**A sixth sense for AI coding agents.**

A spider doesn't see every thread of its web. It *feels* them: the faintest vibration
tells it where something is wrong, before anything breaks. coderachnid gives your coding
agent that sense. It is a Claude Code plugin that loads hard-won engineering discipline
exactly when it is needed: security designed in from the first line, precise code with
no truncation or hidden assumptions, tests that can actually fail, database work that
never touches the original, and a running log of every trap already paid for.

## Why

There's a joke about AI-built apps: they are like poorly sifted cement. Everything is
dumped in at once, lumps and all, and when you press it into the mold it cracks and
leaves holes. Code written by hand with discipline is like well-sifted cement: it
spreads evenly and sets dense and solid.

The model is already intelligent. What it lacks is **memory of what went wrong before**
and **the reflex to check instead of assume**. Every rule in this plugin was paid for in
a real project: a test that passed while the feature was broken, a backup that didn't
restore, a process kill that took down another app, a "zero violations" report from a
check that captured nothing.

## The senses (skills)

| Skill | Activates when | What it adds |
|---|---|---|
| `security-first` | A phase, feature or endpoint starts, and before every commit | Threat modeling, trust boundaries, secret handling, a pre-commit checklist |
| `precise-code` | Writing or changing code | Read before change, no truncation, comments that explain *why*, determinism |
| `tests-that-bite` | Writing tests, fixing bugs, deciding "done" | Positive controls, red-first fixes, mutation testing, golden files |
| `safe-database` | Migrations, schema changes, data fixes, test runs | Backup → migrate → test → verify; disposable test databases; cleanup by id |
| `blind-spots` | Before declaring done, running builds, killing processes | The traps agents repeatedly fall into, and the check for each |
| `phased-plan` | Planning, starting or closing a phase | One ordered plan, frozen scope, one branch per phase, ADRs |
| `response-closing` | The end of every development response | Five points: next phase, keys, watch-outs, tests, next step |
| `pitfall-log` | Something fails in a surprising way | Turns each mistake into a dated rule with the check that catches it |
| `project-setup` | Starting a project or adopting coderachnid | Rules file, plan, ADR folder and database layout from templates |

Stack-specific knowledge lives in each skill's `references/` and is loaded only when the
stack matches: Windows shells, Java/Spring, server-side templates and HTMX, web
frontend, SQLite and MySQL.

## Install

In Claude Code:

```
/plugin marketplace add ru3enaa1/coderachnid
/plugin install coderachnid@coderachnid
```

To try a local clone without installing:

```sh
git clone https://github.com/ru3enaa1/coderachnid
claude --plugin-dir ./coderachnid
```

## Use

The skills activate on their own when the task matches their description. You can also
ask for one by name ("use safe-database before this migration"). To give a new project
the full structure, ask for **project-setup**.

## Design principles

1. **Three layers.** *Senses* (skills) say what to do and why. *Guards* (tests, scripts,
   architecture rules) prove it was done. *Templates* give every project the same shape.
   Instructions alone are suggestions; the guards make them rules.
2. **Every rule comes from a real failure.** It carries its reason and points to a check.
3. **Load only what's needed.** Short skills, with detail in `references/`, to keep the
   agent's context clean.
4. **No hooks by default.** Nothing runs on every turn unless you opt in.
5. **Vendor-neutral.** Patterns, not products.

## What it is not

- Not a code generator or a framework.
- Not a substitute for reading the code. It makes the agent read more, not less.
- Not tied to one language. The core skills are language-agnostic; stack references grow
  with contributions.

## Contributing

New pitfalls are welcome when they were confirmed in a real project. Generalize them,
attach the check that catches them, and see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
