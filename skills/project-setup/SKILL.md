---
name: project-setup
description: Use when starting a new project or adopting coderachnid in an existing one. Creates the project rules file (CLAUDE.md), the development plan, the ADR folder and the pitfall section from templates, adapted to the project's real stack and goals and never copied blindly.
---

# Project setup

Gives a project the same shape from day one, so every session (and every new
contributor) finds the rules, the plan and the history in the same places.

## Steps

1. **Read before writing.** If the project already has a `CLAUDE.md`, a plan, ADRs or
   docs, read them first and *merge*. Never overwrite them.
2. **Ask only what can't be inferred**: the goal and the first milestone, the stack,
   what must never happen (the non-negotiables), and where the real data lives.
3. **Create from the templates in `templates/`:**
   - `CLAUDE.md` from `CLAUDE.template.md`: the project rules (non-negotiables, where we
     really are, architecture, stack, conventions, pitfalls, commands, document map,
     response closing). The template has another name so it isn't loaded as live rules.
   - `DEVELOPMENT_PLAN.md`: goal, frozen scope, phases F0…Fn (see `phased-plan`).
   - `docs/adr/0001-<first-decision>.md`, from `ADR.md`.
   - `database/` with `migrations/`, `schema.sql`, `examples/`, plus `dev/` and
     `backups/` git-ignored (see `safe-database`).
4. **Fill in the real stack and commands**, verified by running them. A command in the
   rules file that was never run is a pitfall waiting to happen.
5. **Set up the guards** for the stack: architecture test, coverage gate, exit-code
   check, `.gitattributes` with LF for byte-compared files, `.gitignore` for secrets,
   backups and local data.
6. **Close with the response block** (see `response-closing`), with F0 as the next phase.

## Rules

- Templates are scaffolding, not content. Delete every section that doesn't apply.
  Never leave a placeholder in a committed file.
- Rules files hold facts and decisions, not wishes. Every rule should be checkable.
