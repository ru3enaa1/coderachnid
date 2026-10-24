---
name: phased-plan
description: Use when starting a project, planning a feature, beginning or closing a phase, or whenever it is unclear what comes next. Keeps one ordered development plan whose phases each state what unlocks them, what they deliver, how to know they are done and which pitfalls await, with one branch per phase and a frozen scope.
---

# Phased plan

The plan is the shared memory between the human and the agent. If it is not in the plan,
it is not decided. If the plan does not say what comes next, nobody knows.

## The plan document

One file at the repository root (`DEVELOPMENT_PLAN.md`) that is followed **in order**.
Template: `../project-setup/templates/DEVELOPMENT_PLAN.md`.

It contains:

1. **The goal and its frozen scope.** What is in the first milestone (MVP) and what is
   explicitly *not*. Anything outside the scope is not built before the milestone.
2. **The phase sequence**, numbered (F0, F1, F2…), from foundations to release.
3. **Each phase** with:
   - **Unlocked by**: what must be true before it starts.
   - **Delivers**: concrete, observable outcomes.
   - **Done when**: the phase's own criteria plus the global definition of done
     (see `tests-that-bite`).
   - **Security**: the threats this phase introduces and their controls
     (see `security-first`).
   - **Pitfalls waiting**: known traps for this phase's stack.
   - **Status**: date, branch, test count and verdict, filled in when it closes.
4. **A map of documents**: which doc holds what (architecture, data, security, design,
   ADRs) and when each one is used.

## Rules

- **Discovery comes before F0** for a new product: market research
  (`/coderachnid:market-research`), the three riskiest assumptions, and the cheapest test
  for each. F0 starts when the owner decides "go" on that evidence, not on enthusiasm.
- **F0 is foundations**: build, tests, architecture tests, coverage gates, the data
  layer with migrations, security baseline, project rules file. Nothing visible to users
  is built on sand.
- **One branch per phase** (`feat/f1-<name>`). Conventional commits. It merges into
  `main` only with the human's approval.
- **Before starting a phase:** read its section, read the existing code, say what is
  missing and what will change, and agree on it *before* writing code.
- **Closing a phase:** run the definition of done, write the status line, update the
  project rules file ("where we really are"), merge.
- **Scope changes are decisions.** Record them in an ADR with date and reason, and update
  the plan. Never let the scope drift quietly.
- **Every architectural decision gets an ADR** (`docs/adr/NNNN-title.md`): context,
  options, decision, consequences. Template: `../project-setup/templates/ADR.md`.
  Smaller decisions made on the way (a library version, a formula detail) go, dated,
  in the document they govern, not in a new ADR.
- **Product intent becomes a constraint.** When the owner restates what the product
  must or must not do, encode it: a required field in the data schema, a check, a test.
  Tone alone drifts within a few sessions; a failing test doesn't.
- **Work in sub-steps inside a phase**, each ending with a recommended test the owner
  can run in minutes. Move on only after the owner confirms.
- **Ask for inputs one step ahead**: mockups, copy or data that a screen needs are
  requested in the sub-step before it, so work never waits on them.
- **Review each mockup as a table before building the screen**: what the mockup says,
  what gets built, and why they differ. Deviations are explained and the designer sees
  which rule won.
- **Keep a living table of recommendations** (R1…Rn): whatever a closing recommends and
  isn't applied in that step goes in, with what, why and who receives it, and is marked
  "applied" when done. Nothing recommended gets lost between sessions.
- **For a non-technical owner, a top-down document** of the whole system, updated when
  each sub-step closes, plus one short learning note per phase (what was built, why it
  matters, an analogy). It keeps decisions theirs.
- **The end client never sees "coming soon".** What doesn't exist yet doesn't appear on
  screen, in documents or in their table of contents.
- **Dependencies enter in the phase that needs them** (how to pick the version:
  `precise-code`).
- **The project rules file always says where the project really is** (current phase,
  what is closed, what is next), so a new session can start without re-explaining.
- **After the milestone, validate in the field** before adding phases. The product is
  judged by real use, not by features shipped.
