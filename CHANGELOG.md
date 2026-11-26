# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com) and the project uses
[Semantic Versioning](https://semver.org).

## [Unreleased]

## [0.9.2] - 2026-11-26

`adr-guard`'s sixth sense, sharpened: it speaks once, with the complete command, and
the two sessions talk through standard blocks (D-016, update).

### Added

- **The recommendation block.** When a risky change is handed back, the closing (and the
  triage, when asked) gives a fixed block: why, with the file that shows the trigger; the
  scope (ADR, base and head commits); the complete command to run in a new session; and
  what to bring back. For `plan`, the quoted task carries what the new session needs.
- **The result block.** Every audit and every plan ends with an `adr-guard result` block
  to paste into the session that asked: verdict, the report's path, clause and finding
  counts, what to fix first, conditions, what was not verified, and the next action with
  the re-audit command when one is needed.
- **The result came back.** Pasting that block makes the working session open the
  report, act on the verdict (blockers first, a failing test before each fix, inside the
  scope fence), leave the ADR and the report untouched, and say whether a re-audit is
  needed.
- **Rules for staying quiet:** certain or silent (a trigger shown by a file or a line),
  nothing while still building, the block once when the change is handed back, not again
  for later steps of the same change, once more only when the code is going out.
- An optional quoted note on `audit` says what to look at hardest without narrowing the
  coverage. When the disposable copy for the positive control can't be made, the audit
  reports it as not performed and the verdict is INCONCLUSIVE.
- Evals: the result-comes-back case, block graders on triage, plan and audit,
  `check-patterns.mjs` (40 controls), and `check-closing.sh` with a "say it once" case in
  a real two-turn conversation.

### Changed

- The closing no longer waits for the tests to pass before recommending the audit: a
  first version of the rule made it defer the command.

## [0.9.1] - 2026-11-23

A fourth round of field lessons (D-012), from a second source project's last weeks:
multi-company roles, an installable web app and a phone-first redesign. No skill or
description changed.

### Added

- `web-frontend.md`: a `flex: 1` child ignores its height; a `legend` sits on its
  fieldset's border; a class's `display` beats `hidden`; auto-growing textareas measured
  from `height: 0`; `100dvh` on Android after navigating back; headless focus emulation;
  capture with the GPU on for `backdrop-filter`; one calculation on server and browser
  made twins (rounding, number printing, `StrictMath`). New section on installable web
  apps: the Android splash colors, no `theme_color` with themes, and iPhone's installed
  app not sharing Safari's cookies.
- `server-templates-htmx.md`: the hidden `_field` after a `th:field` checkbox breaks
  `+` selectors; `LocalDate` in a date input needs `@DateTimeFormat`; Spring's
  transformer cache serving old CSS with `url(...)`; `hx-swap-oob` only in fragments;
  `HX-Reswap: none` still applies out-of-band swaps; buttons outside their form.
- `java-spring.md`: `@WithMockUser` defaults to `ROLE_USER`; two beans of one type in a
  test context; "too many connections" from cached test contexts.
- `windows-shell.md`: settings that split on spaces however quoted (OpenSSH), with the
  8.3 short name as the way out; Docker Desktop restarting its engine after an update.
- `mysql.md`: claiming a row and reading it back needs a locking read under REPEATABLE
  READ.

### Changed

- `java-spring.md`: "Unresolved compilation problems" now covers both cases: a broken
  class left by the editor, and a real source error Maven never reported because it
  reused the editor's class.
- `windows-shell.md`: the double-quotes trap covers every native program, not only `git`.

## [0.9.0] - 2026-11-23

Decide before, audit after: `adr-guard`, with a sixth sense that says when a change
deserves it (D-016). 15 skills.

### Added

- Skill `adr-guard`, visible to the model for a read-only triage only: asked whether a
  task needs a deep review, or working on a change that touches authentication, money,
  personal data, a schema, a public API, security settings or code delivered to others,
  it answers in a few lines with the exact command, or says it isn't needed. The heavy
  modes start only when the user asks:
  - `/coderachnid:adr-guard plan "<task>"` writes the ADR with numbered decision
    clauses, an objective check for each (a fitness function), a scope fence, the damage
    to watch, the rollback and open questions, plus a baseline of the build and tests;
  - `/coderachnid:adr-guard audit <ADR> <base>` checks the code against it in a fresh
    session: six lenses (compliance, correctness, security, damage, direction,
    operations), every clause's check run, a comparison with the baseline, probes and a
    planted defect in a separate worktree, a coverage ledger with no empty cell, and a
    verdict by written rules: APPROVE, APPROVE WITH CONDITIONS, INCONCLUSIVE or BLOCK.
  - References: `plan.md`, `audit.md`, `audit-lenses.md`, `review-report.md`.
- The closing names the `adr-guard` command when a change needs it: in the output style,
  `response-closing` and the `CLAUDE.md` template.
- `docs/GETTING-STARTED.md`: a guide for first-time users that takes a project from an
  empty folder to its first release, in the order the skills are used: what to type at
  each stage, what you get, what is asked of you, a cheat sheet, and how to update,
  switch off and troubleshoot.
- Evals for `adr-guard` (`evals/adr-guard/`): a fictional service with one clean and
  three defective implementations, each defect proven real first; triage, plan and audit
  cases with positive-controlled graders, and `check-closing.sh` for the closing line in
  real sessions. Audit 8 of 8, triage 6 of 6, closing 4 of 4, plan 2 of 2.

### Changed

- The ADR template (`project-setup`) gains decision clauses with checks and a scope
  fence; `phased-plan` points risky changes to `adr-guard`.
- README: install rewritten around the `claude` CLI and `--scope local` (one project
  only), with the two-step update and installs tied to the folder's path; claims that
  stopped being true corrected; the order of use and the discovery chain shortened to a
  summary that links to the guide.

## [0.8.0] - 2026-11-17

Validation before sizing, a PRD of its own, and a working loop sourced from published
engineering practice (D-015). The first real run of the discovery chain showed where it
fell short; no model-invoked description changed.

### Added

- `market-research` frames the idea as a problem and splits it into claims before
  searching, with the "don't build" signals written first; a discovery mode for when
  there is a field but no idea yet; a new step for **demand signals** (people describing
  the problem in open communities, at least one of them peer-to-peer) and one for
  **proven demand** (products that already earn money, and the model worth adapting); a
  **validation scorecard** with a verdict per claim.
- `market-research/references/demand-signals.md`: where people talk, search patterns
  that find the pain, a six-step signal-strength ladder, counting independent authors,
  evidence against, saturation, and how to read revenue estimates (modeled from chart
  rankings, gross or net of store fees, in-app purchases only, unreliable for small
  apps).
- Evidence rules: a quote must come from a page opened in the session; a community that
  blocks automated readers is never worked around (the user pastes the thread); report
  sellers are the weakest source for market size.
- `product-brief` writes **`docs/PRD.md`**: what is being built and what it is not, who
  it is for and where it applies, the problem with its verdicts, goals and metrics with
  numbers, core features with ids and priorities, how each journey works step by step
  (failures included), stories with acceptance criteria, quality requirements, data and
  threats, entities, frozen scope, assumptions, a traceability table and a change log.
  Structure and wording rules in `product-brief/references/prd-structure.md`.
- `precise-code`: **the working loop** (understand before typing, let the limits choose
  the design, data first, the simplest version as oracle, small steps, remove special
  cases by reshaping, optimize last with a measurement), with
  `references/engineering-craft.md`: each rule with its reason, its check and its
  published source, and which sources were opened.
- `test-traps.md`: oracles (a brute-force version judging the real one on seeded random
  inputs, shrinking the failure, keeping it as a regression test).
- Chain evals: seven graders for the PRD with a known-good and a known-bad document.

### Changed

- `product-brief` writes two files instead of one: requirements in `docs/PRD.md`,
  design in `docs/BRIEF.md`, requirements first. `phased-plan` and `project-setup` read
  the PRD (an older project may still hold its requirements in the brief).
- `offer` carries the market report's verdicts: a claim marked NOT YET stays an
  assumption.
- `phased-plan`: an owner who builds before validating defers the tests with their
  thresholds unchanged.

## [0.7.0] - 2026-11-09

A third round of field lessons, from the same project's last phases: the MVP, a native
desktop window, the installer, a customer-data importer and the first releases (D-012).
No new skill and no description changed, so the fixed cost per session stays the same.

### Added

- `blind-spots/references/desktop-apps.md`: keep the server in charge and swap only the
  window, a closed list of window permissions, the window starts first and reads a
  one-time link from stdout, a generation number per start, the webview's cache hiding a
  broken control, window captures that never take the whole screen, the packager's
  install folder, a trimmed runtime gated by a real document, signing as a switch, a
  wizard dragged off-screen, release screenshots from a neutral data folder.
- `security-first/references/supply-chain.md`: vulnerability scans inside the release
  build (before the installer exists), reading each CVE because scanners match by name,
  narrow suppressions with a reason, static-analysis exclusions justified in a file,
  SBOM and checksums computed from the shared file, never rebuilding a shared artifact.
- `security-first/references/customer-imports.md`: read a customer's export in memory,
  strike personal headers, hash free identifiers with the file, read = accepted +
  rejected with a `CHECK`, undo that restores, sample exports marked binary.
- `test-traps.md`, new section on screen checks: a positive control for every new
  automated check (reverse-apply the fix), one defect per check, review scripts that
  print the state they reached, server-side state prepared in the same run, expected
  texts that follow the screens, tools that stop checking a placeholder once it is built.
- Rules in `blind-spots` (sample rows in mockups hide scale, a screen reads the method
  from the data, a link "to do X" must find X, public screenshots), `tests-that-bite`
  (mutation score per class, text from data and its final period, labels by real effect,
  text tied to its source, native dialogs behind a port), `precise-code` (one count in
  one place, persisted records next to their port, search indexes that lag behind the
  repository), `sourced-data` (compare ranges, not points), `phased-plan` (stale
  placeholders checked when a phase closes, a future feature's skeleton as empty data)
  and `safe-database` (imports count every row).
- Stack references: orphaned headings and inherited checks in PDFs; one-column grids in
  fixed-height boxes, `aria-current`, collision checks that miss overflowing art, the
  fold, CDP for review state; `Start-Process` quoting, commit messages with quotes,
  symbols in BOM-less scripts, shared log files; null keys in immutable maps, the
  editor compiling into `target/`, the runner's failure marker, multipart in Spring 7;
  SpEL calling public methods only.

### Changed

- `server-templates-htmx.md`: where an edited stylesheet is served from depends on how
  the app runs (`spring-boot:run` served it from the source folder); the old rule said
  only "the build output".

## [0.6.1] - 2026-10-24

### Added

- Evals for the discovery chain (`evals/chain/`): a fictional product with a finished
  market report, `offer` and `product-brief` run by their commands against loose
  prompts, and a known-good and known-bad document for every grader. Commands 1.00 in
  2 of 2 runs each; loose prompts 0.10 (offer) and 0.29 (brief).

### Changed

- `offer` and `product-brief` are no longer marked anticipated: they carry their
  measured result and still ask for real-project failures in `pitfall-log`.
- `market-research` records how each competitor's home page looks; `product-brief`
  looks for the user's material in the repository first, and looks up or asks for the
  competitors' look instead of inventing it.

## [0.6.0] - 2026-10-24

The discovery chain: research → offer → product brief → code (D-014).

### Added

- Skill `offer`, run by hand with `/coderachnid:offer`: reads `docs/MARKET.md` and writes
  `docs/OFFER.md` with a one-sentence value proposition, three price tiers anchored to
  competitor prices (assumptions until tested), a guarantee that can be honored and is
  legal in the regions, why it wins from the free position, the cheapest test of the
  offer with its threshold, and the promises the product must never make. Anticipated.
- Skill `product-brief`, run by hand with `/coderachnid:product-brief`: reads the market
  report, the offer and the user's own references, and writes `docs/BRIEF.md` with a
  design direction, a self-contained mockup prompt, user stories with acceptance
  criteria, personal data and threats, entities and a frozen MVP scope. Anticipated.
- `product-brief/references/art-directed-editorial.md`: eight shared rules, four
  families (Technical Neo-Swiss, Blueprint Engraving, Atmospheric Scene, Hero Object),
  how to choose one against the competitors' look, and guardrails for social proof,
  contrast, weight and rights.

### Changed

- `market-research`: a top-ten problems table ranked by urgency × willingness to pay
  (read from current spend on workarounds), with trend and the three fastest growing;
  the five main competitors with quoted reviews, the customer they ignore, a positioning
  map and the free position.
- `phased-plan`: discovery runs as the chain, one link per session, and the brief's
  frozen scope becomes the plan's.
- `project-setup`: seeds the forbidden-phrases list from the offer and the plan from
  the brief.
- README: 14 skills, the discovery chain.

## [0.5.0] - 2026-10-24

Keep long sessions light, and start projects with evidence (D-013).

### Added

- Second plugin in the same repository, **`coderachnid-relay`** (`plugins/relay/`), opt-in:
  reloads `.coderachnid/HANDOFF.md` after `/clear` or compaction, asks for a handoff when
  a conversation passes a token threshold, warns before resuming a large conversation
  whose cache expired, and keeps every compaction summary. Plain bash, no jq, Python or
  Node. An optional status line shows context and the five-hour usage limit.
- Skill `handoff`: a short handoff file (task, decisions, files, next step, open
  questions) so `/clear` costs nothing. Activation 4 of 4, quiet 2 of 2.
- Skill `market-research`, run by hand with `/coderachnid:market-research`: sourced
  market size, demand drivers, competition, unmet needs from real reviews and money
  flows, ending in the riskiest assumptions and how to test them. No listing cost.
- `phased-plan`: a discovery phase before F0.
- 25 positive controls for the relay hooks and status line (76 in total), and an
  end-to-end check in real Windows sessions.

### Changed

- README: the two new skills, the relay plugin and market research.

## [0.4.0] - 2026-10-23

A second round of lessons from the same project lifecycle, from data loading to PDF
reports (D-012). No new skill: the detail lives in references that load only when
needed.

### Added

- `precise-code/references/reproducible-outputs.md`: your own generator with its test
  vector, one random stream per datum, canonical inputs, money rounded once at
  persistence, one formatting rule per number, stable tie-breaks, strict math, byte-
  identical PDFs, time zone from the data.
- `blind-spots/references/documents-and-pdf.md`: model before view, the snapshot not the
  present, CSS for the most limited engine, XML-only PDF engines, `@media` order, glyphs
  checked in the font, PDF/UA alt text, page-by-page image review, quiet logging that
  keeps diagnostics.
- `tests-that-bite/references/test-traps.md`: negative cases that can produce output,
  mutation survivors read as questions, known equivalent mutants, clock-safe dates,
  absence checks that skip embedded CSS, banned phrases over generated output, writer
  and reader round-trips, permuted-order determinism, review tools that close what they
  open.
- `precise-code` Dependencies: read release notes and license for usage clauses
  (including clauses about AI agents), pin a whole transitive family, skip same-day
  releases, ban optional script engines.
- `safe-database`: guarded `DROP`, old-format fixtures built by migrating, renamed
  migrations leaving stale build copies. SQLite: `ADD COLUMN` rewriting stored DDL,
  ASCII-only `lower()`, drivers scanning the temp folder.
- `phased-plan`: mockup reviewed as a table, a living table of recommendations, a
  top-down document for the owner, never "coming soon" to the end client.
  `response-closing` sends unapplied recommendations to that table.
- Pitfalls: `.ps1` encoding and `Stop` with redirection, Python heredocs in cp1252,
  folder-wide `eol` rules hitting binaries, browser extensions in clean profiles,
  one-time keys, screen-reader labels stretching scrollers, SVG attributes under CSP,
  `__...__` preprocessing, template engines without their framework, stale nested jars,
  native access on recent Java, framing one route only, logging on paths without the
  framework.

### Changed

- `blind-spots` also activates on generated documents and PDFs (all 8 of its cases,
  15 of 15 runs).

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

[Unreleased]: https://github.com/ru3enaa1/coderachnid/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/ru3enaa1/coderachnid/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/ru3enaa1/coderachnid/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/ru3enaa1/coderachnid/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/ru3enaa1/coderachnid/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ru3enaa1/coderachnid/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ru3enaa1/coderachnid/releases/tag/v0.1.0
