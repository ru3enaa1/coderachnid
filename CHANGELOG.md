# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com) and the project uses
[Semantic Versioning](https://semver.org).

## [Unreleased]

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

[Unreleased]: https://github.com/ru3enaa1/coderachnid/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ru3enaa1/coderachnid/releases/tag/v0.1.0
