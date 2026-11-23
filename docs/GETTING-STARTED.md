# Getting started with coderachnid

This guide takes a new project from an empty folder to its first release, in the order
the skills are meant to be used: what to type at each stage, what you get, and what is
asked of you. The [README](../README.md) is the short version; come back here when you
start a project.

**What you need:** Claude Code (the terminal app or an IDE extension), git, and a folder
for the project. On Windows, the optional relay plugin runs its hooks with Git Bash.

## The map

coderachnid has 15 skills, and they work at different moments:

| Moment | Skills | How they start |
|---|---|---|
| Discovery, before any code | `market-research`, `offer`, `product-brief` | you type their command |
| Setting up the project | `project-setup` | you ask for it |
| Building, phase by phase | `phased-plan` | you ask for a phase |
| While you build | `precise-code`, `tests-that-bite`, `security-first`, `safe-database`, `sourced-data`, `blind-spots`, `pitfall-log` | on their own, when the task matches |
| A change where a mistake is expensive | `adr-guard` | it tells you when it's worth it; plan and audit run when you type the command |
| Every reply and every long session | `response-closing`, `handoff` | the output style, or when the conversation grows |

## Stage 0 · Prepare the project (once)

1. **Create the folder and start git** (`git init`). If the repository will be public,
   set a no-reply email for it first: every commit stores the author's address.
2. **Install coderachnid for this project only**, from a terminal inside the folder:

   ```sh
   claude plugin marketplace add ru3enaa1/coderachnid      # once per machine
   claude plugin install coderachnid@coderachnid --scope local
   claude plugin install coderachnid-relay@coderachnid --scope local   # optional
   ```

   `--scope local` turns the plugin on in this folder and nowhere else, so other projects
   don't pay for its skill descriptions. The relay is optional: it keeps long sessions
   light (Stage 4).

   No `claude` command in your terminal? The VS Code extension ships the CLI inside its
   own folder; on Windows it is
   `%USERPROFILE%\.vscode\extensions\anthropic.claude-code-<version>\resources\native-binary\claude.exe`.
   Some IDE extensions don't offer the `/plugin` command; the CLI always works.
3. **Turn on the five-point closing for this project.** After the install, the folder has
   `.claude/settings.local.json`; add the `outputStyle` line:

   ```json
   {
     "enabledPlugins": {
       "coderachnid@coderachnid": true,
       "coderachnid-relay@coderachnid": true
     },
     "outputStyle": "coderachnid:closing"
   }
   ```

4. **Keep personal files out of git.** Add to `.gitignore`:

   ```gitignore
   .claude/settings.local.json
   .coderachnid/
   ```

5. **Check it.** Open the folder in a new session and run `/context`: the eleven skills
   that start on their own are listed. The three discovery skills are not, on purpose:
   they cost nothing until you type their command. `claude plugin list`, run inside the
   folder, shows coderachnid as enabled there.

## Stage 1 · Discovery (one command per session)

Each command writes a file that the next one reads, so run each in its own session and
type `/clear` between them. A fresh session costs less than a long one, and nothing is
lost: the files carry the thread.

### 1 · `market-research`: is the idea worth building?

```
/coderachnid:market-research "idea or problem" "customer" "industry" "regions"
```

For example: `"freelance designers lose track of unpaid invoices" "freelance designers"
"invoicing software" "Spain and Mexico"`.

What happens:

- It restates the idea as a problem and splits it into claims (the problem exists, these
  people have it, they already spend on it, they want this solution). If you live the
  problem yourself, it interviews you first.
- It writes down the signals that would mean "don't build" before it searches.
- It looks for people already describing the problem in communities, forums and reviews.
  It quotes only pages it could open; if a site blocks automated reading, it asks you to
  open the thread and paste it.
- It finds products that already earn money from the problem, and reads revenue
  estimates for what they are: models, not measurements.
- It sizes the market, ranks the top ten problems, and maps the five main competitors
  and the position none of them holds.

What you get: `docs/MARKET.md`, ending in a verdict for each claim (validated, partly,
not yet, contradicted) and the three riskiest assumptions, each with the cheapest test
you can run this week.

What you decide: go, don't go, or build first and run those tests later. If you build
first, the plan records the tests as deferred, with their thresholds unchanged.

If Claude Code asks for permission to search the web and open pages, allow it: without
web access the skill delivers only a research plan.

### 2 · `offer`: what you sell, to whom, at what price

```
/coderachnid:offer "product name"
```

A working name is fine. If you have none, ask here for a few proposals that don't clash
with the competitors in the report or with registered brands.

What you get: `docs/OFFER.md` with a one-sentence value proposition, three price tiers
anchored to competitor prices (marked as assumptions until tested), a guarantee you can
honor, the cheapest test of the offer with its success threshold, and the promises the
product must never make.

### Before step 3 · Your references

Put what you already have in a `brand/` folder: logo, typefaces, colors, screenshots of
pages or apps you like (and why), and what you don't want. The next skill reads that
folder first and asks only for what is missing. Your taste always wins over its
proposals.

### 3 · `product-brief`: requirements and design

```
/coderachnid:product-brief "product name"
```

What you get:

- `docs/PRD.md`, the requirements: what is being built and what it is not, who it is
  for and where it applies, the problem with its evidence, goals with numbers, core
  features with ids and priorities, how each journey works step by step (failures
  included), user stories with acceptance criteria, personal data and threats, data
  entities, and the frozen scope of the first version.
- `docs/BRIEF.md`, the design direction: how the competitors look, the look none of
  them uses, a branding skeleton, the layout of each screen, and a mockup prompt.

Then:

- **Mockups.** Paste the mockup prompt into your design tool or image generator and save
  the results in `mockups/`. Ask: *"Review mockups/home.png against the brief as a
  table: what the mockup says, what gets built, and why they differ."*
- **Your shape.** *"Adjust the design direction with brand/ref-3.png."* The section is
  rewritten and the change is logged.
- **Go.** When the PRD says what you want built, give the go-ahead.

## Stage 2 · Set up the project

### 4 · `project-setup`: the skeleton

First the technical decision:

> *Propose the stack for this PRD in an ADR with two or three options, and wait for my
> decision.*

Then:

> *Use project-setup with docs/PRD.md as the base.*

It asks only what it can't infer, and writes:

- `CLAUDE.md`, the project's rules: non-negotiables, where the project stands, stack,
  verified commands, a section for pitfalls, and the closing line;
- `DEVELOPMENT_PLAN.md`, with phases that name the PRD's features;
- `docs/adr/0001-…`, the first decision;
- `database/`, with migrations, a readable schema and example data;
- `guards/`, ready-made checks for the project; the forbidden phrases come from the
  offer.

## Stage 3 · Build, phase by phase

### 5 · `phased-plan`: one phase at a time

> *Start F0.*

Then F1, F2… In every phase:

- the work goes on its own branch;
- before writing code, the agent says what is missing and what will change, and you
  agree on it;
- the phase moves in small sub-steps, each ending with a test you can run in minutes;
- closing the phase runs the definition of done, updates where the project stands, and
  merges only with your approval.

F0 is foundations (build, tests, data layer, security baseline); nothing users see is
built before it.

### While you build: the skills that step in on their own

You don't call these. You can still ask for one by name: *"use safe-database before
this migration"*.

| # | Skill | Steps in when… | What you'll notice |
|---|---|---|---|
| 6 | `precise-code` | code is written or changed | it restates the task and works an example first, designs around the data, writes the simplest correct version, moves in small steps, and never leaves `// rest unchanged` |
| 7 | `tests-that-bite` | a bug appears, or something is about to be called done | the failing test comes before the fix, and each new check is proven able to fail |
| 8 | `security-first` | routes, forms, imports, logins or personal data are touched; each phase starts; before each commit | threats and their controls, a test for every control, a checklist before committing |
| 9 | `safe-database` | migrations, schema changes or data fixes | a verified backup first, then migrate, test and verify; tests never touch your real data |
| 10 | `sourced-data` | the product shows figures people rely on | a source, a date and a range for every figure: no source, no number |
| 11 | `blind-spots` | CSS, templates, PDFs, scripts or builds; before saying "done" | screenshots at your real screen sizes, real exit codes, the known traps of your stack |
| 12 | `pitfall-log` | something behaves unexpectedly, or a fix fails | a dated rule in the project's `CLAUDE.md` (Pitfalls), with the check that catches it |

### 13 · When a mistake would be expensive: `adr-guard`

For code you deliver to an organization or a client, code written mostly by AI agents,
or a feature that handles money, identity or personal data.

- **The sixth sense.** Ask *"does this task need adr-guard?"*, or just work: when a
  change touches authentication, money, personal data, a schema, a public API, security
  settings or code that goes to someone else, the closing names the exact command. The
  check is read-only: it never builds, tests or writes anything to decide.
- **Before the code:** `/coderachnid:adr-guard plan "<the task>"` writes the ADR with
  numbered decision clauses, an objective check for each one, a scope fence (what may
  change, what must not), the damage to watch and the rollback, plus a baseline of the
  build and tests today. You accept the ADR; the clauses become the brief for whoever
  implements.
- **After the code**, in a fresh session: `/coderachnid:adr-guard audit <ADR> <base>`.
  It reads every changed hunk through six lenses (compliance, correctness, security,
  damage, direction, operations), runs each clause's check, compares with the baseline,
  proves suspected defects with probe tests in a separate worktree, and plants a known
  defect to make sure the review itself can catch one. The verdict is APPROVE, APPROVE
  WITH CONDITIONS, INCONCLUSIVE (a critical check couldn't run) or BLOCK, and it never
  approves with a gap in its coverage.
- **What it is not:** it raises confidence, it can't prove the absence of bugs, and it
  doesn't replace the organization's own review or security testing.

## Stage 4 · Keep the thread

| # | Skill | When | What it does |
|---|---|---|---|
| 14 | `response-closing` | every development reply (the output style from Stage 0) | ends with five points: next phase, keys, watch-outs, tests to run, next step |
| 15 | `handoff` | the conversation has grown long | writes `.coderachnid/HANDOFF.md`; then type `/clear` |

With the relay, the handoff is automatic: past about 120,000 tokens it asks for one, and
the next session starts with it loaded. Every message re-reads the whole conversation,
so this is what keeps long projects affordable.

## Stage 5 · Release and after

- **Before publishing:** `security-first` runs the vulnerability scan inside the release
  build, before packaging, and computes checksums from the file you share; `blind-spots`
  covers installer traps and screenshots that must not show your own paths.
- **After the first milestone:** run the tests you deferred in discovery, and validate
  with real users before adding phases.
- **Found a new trap?** It is welcome in coderachnid: see
  [CONTRIBUTING.md](../CONTRIBUTING.md).

## Cheat sheet

| Moment | What you type | What you get |
|---|---|---|
| Prepare | `claude plugin install coderachnid@coderachnid --scope local` | coderachnid on in this project only |
| Market | `/coderachnid:market-research "…" "…" "…" "…"` | `docs/MARKET.md` |
| Offer | `/coderachnid:offer "…"` | `docs/OFFER.md` |
| References | your files in `brand/` | |
| Requirements and design | `/coderachnid:product-brief "…"` | `docs/PRD.md`, `docs/BRIEF.md`, mockups |
| Skeleton | *"Propose the stack in an ADR…"*, then *"Use project-setup…"* | `CLAUDE.md`, the plan, the first ADR, `database/`, `guards/` |
| Build | *"Start F0"*, *"Start F1"*… | the product, phase by phase |
| A risky change | *"Does this need adr-guard?"*, then `/coderachnid:adr-guard plan "…"` and, after, `audit` | ADRs with checks; an audit with a verdict |
| Long sessions | *"Write the handoff"*, then `/clear` | the thread kept in a few hundred words |

## Updating, switching off, troubleshooting

- **Update**, inside the project:

  ```sh
  claude plugin marketplace update coderachnid
  claude plugin update coderachnid@coderachnid --scope local
  ```

  The first command only refreshes the catalog: the installed plugin keeps its version
  until the second one runs.
- **Switch it off in a project:** `claude plugin disable coderachnid@coderachnid --scope
  local`; `enable` turns it back on.
- **Renamed or moved the folder?** A local install is tied to the folder's path: run the
  install again inside the new folder.
- **A `/coderachnid:` command isn't recognized:** the plugin isn't enabled in this
  folder. Run `claude plugin list` inside it, install with `--scope local` if needed, and
  start a new session.
- **`/plugin` isn't recognized:** some IDE extensions don't offer it. Use the `claude`
  CLI from a terminal.
- **On a capped plan:** install only where you use it, run each discovery command in its
  own session (market research is the heaviest; start it at the beginning of a usage
  window), and let the handoff keep sessions short.
