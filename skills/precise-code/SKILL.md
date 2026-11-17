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

## The working loop

How experienced engineers go from a requirement to working code. Sources, reasons and
checks for each step: `references/engineering-craft.md`.

1. **Understand before typing.** Restate the task with its inputs, outputs and limits,
   and work one example by hand. That example is the first test.
2. **Let the limits choose the design:** how many records, how many people at once, how
   fast, on which device. Without those numbers "simple" and "scalable" are opinions.
3. **Data first.** Decide what is stored, how it relates and what must always be true of
   it. The code follows from that.
4. **Write the simplest version that is obviously right**, brute force included when
   the sizes allow. It stays afterwards as the oracle.
5. **Small steps, each one run.** When a change is hard, first make it easy without
   changing behavior, then make it.
6. **Remove special cases by reshaping the data**, not by adding branches.
7. **Check the real version against the obvious one** on seeded random inputs
   (see `tests-that-bite`), and look at it running.
8. **Optimize last**, with a measurement before and after.

A prototype built to learn is thrown away; what it taught goes into the plan.

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
  with a message the user can act on. When validating input written by people, collect
  every problem (with file and path) instead of stopping at the first.
- **Money:** integer minor units in storage, decimal types for presentation. Never
  binary floating point.
- **Boundaries:** controllers expose DTOs, never database rows or entities. Repositories
  hold no business logic. Templates are dumb: every number arrives precomputed.
- **Partial updates:** `null` means *don't touch*, empty means *clear*. A form that
  omits a field must not erase it.
- **One count, one place.** A number or a sentence shown on several screens or documents
  is built by one function in the core. A count written in four places with two rules was
  fixed in one; the fourth, a PDF footer, only showed up in the page image.
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
- **Version plus content hash.** A version number alone doesn't pin data: someone edits
  it and forgets to bump. Hash the content, after normalizing line endings and removing
  a BOM, so the same data gives the same hash on every OS.
- **Outputs that must reproduce exactly** (simulations, reports, drawings compared byte
  for byte) need your own generator with its test vector, one random stream per datum,
  a canonical input, strict math and fixed document metadata. Details:
  `references/reproducible-outputs.md`. Documents rendered to screen and PDF:
  `../blind-spots/references/documents-and-pdf.md`.

## Dependencies

- **One at a time**, in the step that needs it, so a failure has one suspect.
- **Check the version against the registry's metadata that day**, never memory or a
  blog post. When the framework manages a library, take the latest patch of the line it
  supports, not the next minor. Search indexes lag: one was months behind on two
  frameworks. Read the repository's own directory listing, and sort versions as numbers
  (an alphabetical listing puts `11.0.9` after `11.0.27`).
- **Read the full dependency tree** after adding one. A filtered view can hide the
  transitive dependency that causes the conflict. When a library pulls an old family of
  modules, pin every module of that family, not only the ones it names.
- **Read the release notes and the license before adding**, looking for usage clauses.
  A library's new version asked not to be used with AI agents: respect it and take
  another path.
- **Skip same-day releases**; wait for the version to settle. Ban optional script engines
  a library can pull in (with the build's enforcer or equivalent).

## Data written by people

Rules, content or configuration in YAML or JSON that people edit is code: closed
structures, strict loading, every error at once, a test per format trap. Details:
`references/data-as-code.md`.

## Architecture that enforces itself

- Keep the core free of frameworks (no web, SQL or JSON library imports) and **enforce
  it with an architecture test** (ArchUnit, dependency-cruiser, import-linter).
- Ports and adapters: the core declares interfaces and the outer modules implement them.
- **Persisted records live next to the port that stores them**, and the logic that
  proposes them in its own package. Kept with their proposer, they made a package cycle
  through the storage port.
- Decisions that shape the code go in numbered ADRs.

## Before saying "done"

- It compiled, **checked by the real exit code**.
- Tests ran and passed. If it is an app, it started and the change was seen working.
- **Never mark as done something that did not compile and was not tested.** State
  exactly what was verified and what was not.
- No process left running. Stop by PID or port, never by process name.

See `blind-spots` for the traps that hide behind "it compiles".
