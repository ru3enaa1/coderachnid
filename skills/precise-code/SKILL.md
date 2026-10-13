---
name: precise-code
description: Use whenever writing, modifying or refactoring code. Enforces read-before-change, no truncation, comments that explain why, named constants, small focused units, immutability, explicit error handling and determinism, so the codebase stays coherent and free of hidden assumptions as it grows.
---

# Precise code

Just enough code, written completely, so the next reader (human or model) never has to
guess. Gaps appear where something was assumed, truncated or left implicit.

## Before changing anything

1. **Read what is there**, including its tests. Never assume that a function, file,
   column or API exists or behaves a certain way: open it.
2. **For anything bigger than a small fix, say in a few lines what is missing and what
   will change**, and agree on it before writing code.
3. **Match the surrounding code**: naming, idiom, comment density, structure. A new
   pattern needs a reason (and, if it is architectural, an ADR).

## While writing

- **Never truncate.** No `// ... rest unchanged`, no placeholders, no
  `TODO: implement`. Every file you write is complete and compiles.
- **Just enough.** Solve what was asked. No speculative abstraction and no unrequested
  feature (YAGNI), but also no shortcut that leaves a hole for later.
- **Comments explain *why***: the decision, the constraint, the pitfall avoided. Not
  *what* the line does. Every constant carries its reason:
  `TIMEOUT = 5s // upstream SLA is 3 s, plus margin`.
- **Named constants** for every threshold. Business thresholds live in configuration or
  knowledge data, not hard-coded in logic.
- **Small units:** functions under 50 lines, files under ~400, nesting at most 4 levels.
  Prefer early returns.
- **Immutability by default:** value objects and records, defensive copies of
  collections, sealed or closed result types.
- **Explicit errors:** no empty `catch`, no catch-all that hides the cause. Fail fast,
  with a message the user can act on.
- **Money:** integer minor units in storage, decimal types for presentation. Never
  binary floating point.
- **Boundaries:** controllers expose DTOs, never database rows or entities. Repositories
  hold no business logic. Templates are dumb: every number arrives precomputed.
- **Partial updates:** `null` means *don't touch*, empty means *clear*. A form that
  omits a field must not erase it.
- **One language per concern.** Choose the language of domain terms and of technical
  structure once, and keep to it.

## Determinism

Same input + same code version + same data = the same output, byte for byte.

- **Inject time and randomness** (a clock, a seed). No `now()` or unseeded random in
  core logic. An architecture test enforces this.
- **Always set locale and time zone explicitly** when formatting or parsing numbers and
  dates. Defaults differ between machines.
- **The user's "today" uses the user's zone.** At 9 p.m. in UTC−5 it is already
  tomorrow in UTC.
- **Never rely on hash-map iteration order** for output, hashing or seeds.
- **Round once, in one tested place.** Two languages round x.xx5 differently, so a
  value rounded in the UI and again on the server will drift.

## Architecture that enforces itself

- Keep the core free of frameworks (no web, SQL or JSON library imports) and **enforce
  it with an architecture test** (ArchUnit, dependency-cruiser, import-linter).
- Ports and adapters: the core declares interfaces and the outer modules implement them.
- Decisions that shape the code go in numbered ADRs.

## Before saying "done"

- It compiled, **checked by the real exit code**.
- Tests ran and passed. If it is an app, it started and the change was seen working.
- **Never mark as done something that did not compile and was not tested.** State
  exactly what was verified and what was not.
- No process left running. Stop by PID or port, never by process name.

See `blind-spots` for the traps that hide behind "it compiles".
