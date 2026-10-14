# Guards

The third layer. Skills say what to do; guards prove it was done. A guard passes by its
exit code, never by its text, and **every guard has a positive control**: a known-bad
fixture it must fail on. A check that has never failed proves nothing.

## Guards for this repository

| Guard | What it proves | Run |
|---|---|---|
| `check-skills.sh` | Every skill has valid frontmatter, a name matching its folder, a trigger-worthy description, a short body and no dangling `references/` or `templates/` paths; the skill count in the README badge and banners matches the folders | `bash guards/check-skills.sh` |
| `check-private-terms.sh` | No private term (people, companies, paths, private repositories) appears in a publishable file | `bash guards/check-private-terms.sh` |

`check-private-terms.sh` reads its list from `.private-terms` at the repository root. That
file is git-ignored on purpose. Create it locally with one term per line. Before a
release, run it with `--history`: it also scans every commit, because on a public
repository a term removed in a later commit is still readable.

## Guards for projects

Shipped as templates of the `project-setup` skill, in
`skills/project-setup/templates/guards/`, and copied into a project's own `guards/`.

| Guard | What it proves | Run |
|---|---|---|
| `check-forbidden-phrases.sh` | No phrase from a list (promises the product must never make) appears in user-facing text | `bash guards/check-forbidden-phrases.sh <list> <path>...` |
| `check-line-endings.sh` | Byte-compared files are pinned to LF in `.gitattributes` and have no CRLF on disk | `bash guards/check-line-endings.sh '<pathspec>'...` |
| `run-checked.sh` | A build or test command's real exit code, not the one a pipe or a red console reports | `bash guards/run-checked.sh -- <command>` |
| `backup-before-migrate.sh` | A verified backup exists before a migration runs: SQLite (online backup API, integrity check, row counts) or MySQL (`mysqldump --single-transaction`, complete dump, no password on the command line) | `bash guards/backup-before-migrate.sh sqlite\|mysql <db> <backup-root> <reason> && <migrate>` |

The MySQL path is tested against a stand-in `mysqldump` (good, failed and truncated
dumps). Running it against a real server is still **anticipated**: confirm it on the
first project that uses it.

## Exit codes

All guards share one convention:

- `0` clean
- `1` a violation was found
- `2` nothing could be checked (missing list, no matching file, not a git repository).
  This is never reported as clean.

## Positive controls

`guards/tests/test-guards.sh` builds a temporary fixture for every rule of every guard
above, checks that each bad fixture fails with the documented code and that a clean one
passes, then deletes the fixtures. The real repository is never modified.

```sh
bash guards/tests/test-guards.sh; echo $?     # 0 only when every expectation holds
```

Run it after changing any guard. It already caught a real bug: Git for Windows' grep
strips the carriage return at the end of each line, so the first `check-line-endings.sh`
reported a CRLF file as clean.

## Roadmap

- Backups for PostgreSQL (`pg_dump`), with the F5 stack references.
- Optional, opt-in hooks that call these guards. Off by default (see `docs/DECISIONS.md`, D-004).
