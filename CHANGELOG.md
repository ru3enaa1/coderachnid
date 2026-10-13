# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com) and the project uses
[Semantic Versioning](https://semver.org).

## [Unreleased]

### Added

- Plugin manifest and marketplace file.
- Skills: `security-first`, `precise-code`, `tests-that-bite`, `safe-database`,
  `blind-spots`, `phased-plan`, `response-closing`, `pitfall-log`, `project-setup`.
- References: local web app hardening, LLM integration, SQLite, MySQL, Windows shells,
  Java/Spring, server templates and HTMX, web frontend.
- Templates: project rules file, development plan, ADR.
- README visual identity: sticker logo and banner (dark and light), tagline, honest
  badges, and a welcome aimed at budget-conscious users (D-008).
- `assets/build-assets.mjs`, which regenerates the artwork deterministically.
- `check-skills.sh` now fails if the skill count in the README badge or the banners
  does not match the skill folders.
