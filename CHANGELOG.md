# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com) and the project uses
[Semantic Versioning](https://semver.org).

## [Unreleased]

## [0.3.0] - 2026-10-15

Lessons from a full project lifecycle, generalized (D-012).

### Added

- Skill `sourced-data`: a primary source, date and range for every figure users rely
  on; no search-engine summaries; "no source, no number". Activation 4 of 4, quiet 2
  of 2.
- `precise-code/references/data-as-code.md`: closed structures, strict loading,
  every error at once, one test per format trap, content hashing, real-content tests.
- `precise-code`: a Dependencies section (one at a time, registry metadata that day,
  latest patch of the supported line, full transitive tree) and version plus content
  hash under Determinism.
- `tests-that-bite`: test the real content with a shrinking list of known-pending
  problems; run the packaged artifact once.
- `phased-plan`: product intent becomes a constraint (schema field, check, test);
  sub-steps with a recommended test; inputs requested one step ahead; a learning note
  per phase for non-technical owners; small decisions dated in the document they govern.
- `security-first`: security tests are the phase's acceptance criteria; fit generic
  checklists to the real threat model; review exactly what is staged before committing.
- Pitfalls: real-viewport sizes from the user's screenshots and geometric overlap
  checks (web frontend); Java static fields initialize top to bottom.
- README brought up to date: current triggers in the skills table, all stack
  references, the four project guards, how to update or turn the plugin off, and how
  each part is checked.

## [0.2.1] - 2026-10-14

### Changed

- `blind-spots` now activates when editing or reviewing CSS and page layout, server
  templates (Thymeleaf, HTMX), build files and shell scripts, not only before declaring
  work done. Measured: 0 of 6 runs before, 6 of 6 after, with no regression on its
  earlier cases and no false positive on its "should not" cases.

### Added

- Eval cases for templates and CSS, and `evals/activation/web-fixture.sh`, a sample
  with a Thymeleaf template and a stylesheet.

## [0.2.0] - 2026-10-14

### Added

- Output style `coderachnid:closing`: Claude Code's default behavior plus the
  five-point closing on every development reply, selected once with `/output-style`
  or in settings (D-011). No project needs the `CLAUDE.md` line anymore.

### Changed

- `response-closing` recommends the output style first and the `CLAUDE.md` line second.
- Pitfall: `MSYS_NO_PATHCONV=1` goes on one command, never exported for a script.

## [0.1.0] - 2026-10-14

First public release.

### Added

- Plugin manifest and marketplace file.
- `check-private-terms.sh --history` scans every commit before a release, and
  `docs/RELEASING.md` holds the release checklist.
- Skills: `security-first`, `precise-code`, `tests-that-bite`, `safe-database`,
  `blind-spots`, `phased-plan`, `response-closing`, `pitfall-log`, `project-setup`.
- References: local web app hardening, LLM integration, SQLite, MySQL, Windows shells,
  Java/Spring, server templates and HTMX, web frontend.
- Templates: project rules file, development plan, ADR.
- README visual identity: sticker logo and banner (dark and light), tagline, honest
  badges, and a welcome aimed at budget-conscious users (D-008).
- `assets/build-assets.mjs`, which regenerates the artwork deterministically.
- Pitfalls harvested from real projects: no-reply commit email on public repositories,
  YAML that loads with the wrong meaning, PowerShell splitting `-D` arguments, silent
  firewall drops, fixed mockup heights, headless browser profiles, fonts in SVG images,
  schema validation failing the whole test suite, and test data folders.
- Activation trial (F1): sample project, 18 prompts, a headless runner and the first
  results, 18 of 18 passing (`evals/`, `docs/F1-TRIAL.md`).
- Eval suite for `claude plugin eval` (F2): 27 activation cases in English and
  Spanish and 4 compliance cases against a no-plugin baseline (`evals/cases/`).
  Results and findings in `docs/F2-EVALUATION.md`.
- D-009: behavior meant for every reply lives in the project rules file.
- F2b value cases (`evals/cases/value/`): import limits, schema change on existing
  data, wildcard bug, closing with a project rule. The plugin wins where the base model
  skips a safeguard (Δ +1.00, +0.50, +0.33).
- README: the line to add to `CLAUDE.md` for a closing on every reply.
- Positive-control suite for every guard (`guards/tests/test-guards.sh`, 51 checks).
- Project guards as `project-setup` templates (D-010): `check-forbidden-phrases.sh`,
  `check-line-endings.sh`, `run-checked.sh` (real exit code of a build) and
  `backup-before-migrate.sh` (verified SQLite or MySQL backup before a migration).
- Pitfall: Git for Windows' grep strips the carriage return before matching.
- `check-skills.sh` now fails if the skill count in the README badge or the banners
  does not match the skill folders.

### Changed

- Descriptions tuned on F2 evidence: `security-first` (concrete triggers),
  `blind-spots` ("ready to ship, merge or release"), `pitfall-log` (user-reported
  failures, while debugging), `response-closing` (load at the start of the task).
- `response-closing` explains that the rules file makes the closing reliable.
- README: the main audience is the $20 monthly plan, whose usage limits reset every
  few hours.
- `response-closing` gives the rules-file line when a project lacks it.
- `security-first` names any endpoint, even one that edits a field; `tests-that-bite`
  leads with reported bugs and a failing test first.

[Unreleased]: https://github.com/ru3enaa1/coderachnid/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/ru3enaa1/coderachnid/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/ru3enaa1/coderachnid/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ru3enaa1/coderachnid/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ru3enaa1/coderachnid/releases/tag/v0.1.0
