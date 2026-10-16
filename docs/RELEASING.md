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

- Bump `version` in **both** `.claude-plugin/plugin.json` and
  `.claude-plugin/marketplace.json` (Semantic Versioning, see `CONTRIBUTING.md`).
- Move the `Unreleased` entries in `CHANGELOG.md` under the new version and date.

## 4. Install on a clean machine

Simulate one with an empty Claude Code configuration folder. Keep its path short:
Windows stops at 260 characters and a deep folder makes `git clone` fail.

```sh
export CLAUDE_CONFIG_DIR="$HOME/.cr-clean"          # empty, short path
claude plugin marketplace add ru3enaa1/coderachnid
claude plugin install coderachnid@coderachnid
claude plugin list                                  # version, enabled
claude plugin details coderachnid                   # 9 skills, 0 hooks
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
