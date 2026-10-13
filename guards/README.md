# Guards

The third layer. Skills say what to do; guards prove it was done. Today the guards
protect this repository. Guards that projects can adopt are on the roadmap.

| Guard | What it proves | Run |
|---|---|---|
| `check-skills.sh` | Every skill has valid frontmatter, a name matching its folder, a trigger-worthy description, a short body and no dangling `references/` or `templates/` paths; the skill count in the README badge and banners matches the folders | `bash guards/check-skills.sh` |
| `check-private-terms.sh` | No private term (people, companies, paths, private repositories) appears in a publishable file | `bash guards/check-private-terms.sh` |

`check-private-terms.sh` reads its list from `.private-terms` at the repository root. That
file is git-ignored on purpose. Create it locally with one term per line.

Both scripts exit with 0 on success and non-zero on failure. Check the exit code, not
the text.

## Roadmap

- A positive-control test for each guard (it must fail on a known-bad fixture).
- Adoptable guards for projects: a real exit-code build wrapper, a forbidden-phrases
  test, an LF check for byte-compared files, and a backup-before-migrate script.
- Optional, opt-in hooks that call these guards. Off by default (see `docs/DECISIONS.md`, D-004).
