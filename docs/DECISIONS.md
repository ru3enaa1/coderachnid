# Decisions

Short records of the choices that shape coderachnid. Newest last.

## D-001 · A plugin, not a single skill (2026-10-13)

A single skill would load everything at once or nothing at all. A plugin bundles several
focused skills that activate independently, and installs from GitHub in two commands.

## D-002 · Three layers: senses, guards, templates (2026-10-13)

Instructions alone are suggestions an agent can skip. Skills (*senses*) are paired with
*guards* (tests, scripts and architecture rules that verify) and *templates* (the same
project shape every time). Guards ship after the skills have been tested; see the roadmap
in `CLAUDE.md`.

## D-003 · English for all plugin content (2026-10-13)

The target audience is international. Skills, references, templates and docs are written
in English. Projects that use the plugin can still respond in their own language.

## D-004 · No hooks by default (2026-10-13)

Nothing runs on every turn unless the user opts in. Any hook shipped later is optional,
documented and off by default.

## D-005 · Original content only (2026-10-13)

No text copied from other plugins or skill packs, whatever their license. Ideas may be
cited; text is written here.

## D-006 · Every rule comes from a real failure, generalized (2026-10-13)

The rules were distilled from the maintainer's previous projects and stripped of names,
paths, customers and private details. Each rule keeps its reason and points to a check.

## D-007 · Name: coderachnid (2026-10-13)

The spider feels every thread of its web and senses the faintest vibration before
anything breaks: a sixth sense added to a model that is already intelligent, making it
sharper and more precise.
