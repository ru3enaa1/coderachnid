# Releasing

The checklist used for v0.1.0. Every step is a command with an exit code; a step that
can't be checked is not done.

## 1. Guards

```sh
bash guards/check-skills.sh && bash guards/check-private-terms.sh --history && bash guards/tests/test-guards.sh
claude plugin validate .
```

`--history` scans every commit, not only today's files: on a public repository a term
removed in a later commit is still readable. The only expected `validate` warnings are
about `CLAUDE.md` and `CLAUDE.local.md` at the root, which are maintainer files.

## 2. History review

- Every commit author and committer uses the GitHub no-reply address:
  `git log --all --format='%ae | %ce' | sort -u`
- No secrets: search tracked files for key prefixes and `key=`/`token=` assignments.
- No personal paths: the only `C:\Users\...` allowed is the generic `C:\Users\First Last`.

## 3. Version

- Bump `version` in `.claude-plugin/plugin.json`, in both entries of
  `.claude-plugin/marketplace.json` and in `plugins/relay/.claude-plugin/plugin.json`
  (Semantic Versioning, see `CONTRIBUTING.md`).
- Move the `Unreleased` entries in `CHANGELOG.md` under the new version and date.

## 4. Install on a clean machine

Simulate one with an empty Claude Code configuration folder. Keep its path short:
Windows stops at 260 characters and a deep folder makes `git clone` fail.

```sh
export CLAUDE_CONFIG_DIR="$HOME/.cr-clean"          # empty, short path
claude plugin marketplace add ru3enaa1/coderachnid
claude plugin install coderachnid@coderachnid
claude plugin install coderachnid-relay@coderachnid # the opt-in hooks plugin
claude plugin list                                  # versions, enabled
claude plugin details coderachnid                   # skills as in the README badge, 0 hooks
rm -rf "$HOME/.cr-clean"
```

This installs what is on GitHub's default branch, so run it after the release commit is
pushed and before the tag.

## 5. Tag

With the maintainer's go-ahead:

```sh
git tag -a vX.Y.Z -m "coderachnid vX.Y.Z"
git push origin vX.Y.Z
```

## v0.9.1 record (2026-11-23)

- Guards: skills 0 (15 skills), private terms with `--history` 0, positive controls 76
  of 76, `validate` passed with the two expected root warnings.
- History: no-reply address only; no secret; no personal path.
- Clean install from GitHub: both plugins at 0.9.1 from commit `40c93cb`; the new rules
  present in the references. Fixed cost unchanged (about 1,639 estimated, about 1,270
  real): only references grew. Tag `v0.9.1` on `40c93cb`.

## v0.9.0 record (2026-11-23)

- Guards: skills 0 (15 skills), private terms with `--history` 0, positive controls 76
  of 76, `validate` passed with the two expected root warnings; cross-skill links
  checked.
- History: no-reply address only; no secret; no personal path.
- Clean install from GitHub: both plugins at 0.9.0 from commit `9d47339`; `adr-guard`
  with its four references, and the output style's new closing line present. 15 skills,
  0 hooks; relay 3 hooks at no model context cost.
- Fixed cost: `plugin details` estimates about 1,639 tokens always on (1,479 before).
  Without the three by-hand skills, which the listing leaves out, about 1,270: the 160
  added are `adr-guard`'s description, the price of a skill the model must know to warn.
- Tag `v0.9.0` on `9d47339`.

## v0.8.0 record (2026-11-17)

- Guards: skills 0 (14 skills), private terms with `--history` 0, positive controls 76
  of 76, `validate` passed with the two expected root warnings. Cross-skill links
  checked.
- No description of a model-invoked skill changed. `plugin details` now estimates about
  1,479 tokens always on (1,432 before), but the difference comes from the longer
  descriptions of `market-research` and `product-brief`, which run by hand and are left
  out of the listing, so the real fixed cost is unchanged (about 1,110).
- Cost when a skill loads: `precise-code`, which loads on coding tasks, grew from 6,439
  to 7,658 bytes (about 300 tokens more per load) with the working loop. The by-hand
  skills grew more (`market-research` and `product-brief` about 1.8k tokens each), but
  they run once per project.
- History: no-reply address only; no secret; no personal path.
- Clean install from GitHub: both plugins at 0.8.0 from commit `ce637d3`; the three new
  references present, `product-brief` writing `docs/PRD.md`, the working loop in
  `precise-code`. 14 skills, 0 hooks; relay 3 hooks at no model context cost. Tag
  `v0.8.0` on `ce637d3`.

## v0.7.0 record (2026-11-09)

- Guards: skills 0 (14 skills), private terms with `--history` 0, positive controls 76
  of 76, `validate` passed with the two expected root warnings. Cross-skill links checked
  by a script with its own positive control (a planted broken link was caught).
- No skill description changed (checked on the diff), so activation is unaffected and
  `plugin details` still estimates about 1,432 tokens always on (about 1,110 in practice).
- History: no-reply address only; no secret; no personal path.
- Clean install from GitHub: both plugins at 0.7.0 from commit `3e5efdd`; the three new
  references present and the corrected static-files rule shipped. 14 skills, 0 hooks;
  relay 3 hooks at no model context cost. Tag `v0.7.0` on `3e5efdd`.

## v0.6.1 record (2026-10-24)

- Guards: skills 0 (14 skills), private terms with `--history` 0, positive controls 76
  of 76, `validate` passed with the two expected root warnings.
- History: no-reply address only; no secret; no personal path.
- Clean install from GitHub: both plugins at 0.6.1 from commit `cced920`; `offer` and
  `product-brief` carry their measured result, `market-research` records competitors'
  look. 14 skills, 0 hooks; relay 3 hooks at no model context cost. Tag `v0.6.1` on
  `cced920`.

## v0.6.0 record (2026-10-24)

- Guards: skills 0 (14 skills), private terms with `--history` 0, positive controls 76
  of 76, `validate` passed (the two expected root warnings, plus a plugin-directory note
  that there is no PNG icon, which doesn't change the result).
- History: every author and committer uses the no-reply address; no secret; no
  personal path.
- Clean install from GitHub: both plugins at 0.6.0 from commit `2827944`. `coderachnid`:
  14 skills, 0 hooks, `offer`, `product-brief` and its reference present. `plugin
  details` estimates about 1,432 tokens always on, but that counts the three by-hand
  skills (about 320 tokens) that the listing leaves out, so about 1,110 in practice.
  `coderachnid-relay`: 0 skills, 3 hooks, no model context cost. Tag `v0.6.0` on
  `2827944`.

## v0.5.0 record (2026-10-24)

- Guards: skills 0, private terms with `--history` 0, positive controls 76 of 76,
  `validate` passed for both plugins (the root with the two expected warnings).
- Clean install from GitHub: both plugins at 0.5.0 from commit `9ea855f`. `coderachnid`:
  12 skills, 0 hooks; `plugin details` estimates about 1,197 tokens always on, but that
  counts `market-research`, which `/context` shows is absent from the listing.
  `coderachnid-relay`: 0 skills, 3 hooks, no model context cost, scripts present.
  Tag `v0.5.0` on `9ea855f`.

## v0.4.0 record (2026-10-23)

- Guards: skills 0, private terms with `--history` 0, positive controls 51 of 51,
  `validate` passed with the two expected warnings.
- Clean install from GitHub: 0.4.0 from commit `ee5763d`, 10 skills, 0 hooks, the three
  new references present; about 1,019 tokens always on (1,012 in 0.3.0). Tag `v0.4.0`
  on `ee5763d`.

## v0.3.0 record (2026-10-15)

- Guards: skills 0, private terms with `--history` 0, positive controls 51 of 51,
  `validate` passed with the two expected warnings.
- README cross-checked against the repository: every skill folder in the table, every
  listed guard and reference present.
- Clean install from GitHub: 0.3.0 from commit `ad789e5`, 10 skills, 0 hooks, new files
  present. `plugin details`: about 1,010 tokens always on (was about 870 with nine
  skills). Tag `v0.3.0` on `ad789e5`.

## v0.2.1 record (2026-10-14)

- Guards: skills 0, private terms with `--history` 0, positive controls 51 of 51,
  `validate` passed with the two expected warnings.
- Clean install from GitHub: 0.2.1 from commit `b80134e`, 9 skills, 0 hooks, new
  `blind-spots` description present. Tag `v0.2.1` on `b80134e`.

## v0.2.0 record (2026-10-14)

- Guards: skills 0, private terms with `--history` 0, positive controls 51 of 51,
  `validate` passed with the two expected warnings.
- Clean install from GitHub: 0.2.0 from commit `0e513be`, 9 skills, 0 hooks, and the
  output style listed as `coderachnid:closing` (checked with `/output-style`; the
  leading `/` needs `MSYS_NO_PATHCONV=1` on that one command in Git Bash).
- Tag `v0.2.0` on `0e513be`.

## v0.1.0 record (2026-10-14)

- Guards: skills 0, private terms with `--history` 0, positive controls 51 of 51,
  `validate` passed with the two expected warnings.
- History: 14 commits, all with the no-reply address; no private term; no secret; one
  generic `C:\Users\First Last`.
- Clean install from GitHub: marketplace added, plugin installed as 0.1.0 and enabled.
  `plugin details`: 9 skills, 0 hooks, 0 agents, 0 MCP servers; about 870 tokens
  always on (the skill descriptions), 500 to 1,100 more when a skill fires.
- The first attempt failed with `Filename too long` because the test folder was deeply
  nested; it passed from a short path. Recorded as a pitfall in
  `skills/blind-spots/references/windows-shell.md`.
