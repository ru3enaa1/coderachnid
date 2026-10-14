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
file is git-ignored on purpose. Create it locally with one term per line.

## Guards for projects

Shipped as templates of the `project-setup` skill, in
`skills/project-setup/templates/guards/`, and copied into a project's own `guards/`.

| Guard | What it proves | Run |
|---|---|---|
| `check-forbidden-phrases.sh` | No phrase from a list (promises the product must never make) appears in user-facing text | `bash guards/check-forbidden-phrases.sh <list> <path>...` |
| `check-line-endings.sh` | Byte-compared files are pinned to LF in `.gitattributes` and have no CRLF on disk | `bash guards/check-line-endings.sh '<pathspec>'...` |

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

- Adoptable guards still to come: a build wrapper that reports the real exit code, and
  a backup-before-migrate script.
- Optional, opt-in hooks that call these guards. Off by default (see `docs/DECISIONS.md`, D-004).
