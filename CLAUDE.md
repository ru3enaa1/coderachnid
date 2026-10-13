# coderachnid — maintainer rules

coderachnid is a Claude Code **plugin** that gives AI coding agents a "sixth sense":
security-first design, precise code, tests that bite, safe database work, phased plans,
a five-point response closing and a pitfall log. Every rule was distilled from real
projects and generalized.

> **If `CLAUDE.local.md` exists, read it first.** It holds the maintainer's private
> context (origin, history, source projects, preferences) and is never published.

---

## 1. Non-negotiables

- **All repository content is in English.** It is written for an international audience.
  The maintainer writes in Spanish: **reply to the maintainer in Spanish**, but write
  every file in English.
- **No private data in publishable files**: no names of people, companies, customers or
  private projects, no personal paths, emails, keys or internal URLs. Before every
  commit, `bash guards/check-private-terms.sh` must exit 0.
- **Original content only.** Never copy text from other plugins or skill packs (for
  example ECC, impeccable or taste-skill), whatever their license (D-005).
- **No hooks by default.** Anything that runs automatically is opt-in and documented
  (D-004).
- **Every rule comes from a real failure**, keeps its reason and points to a check
  (D-006). Anticipated rules are marked as anticipated.
- **Never mark anything as done that wasn't checked.** Guards pass by exit code; skills
  are tried in a real session.

## 2. Where we really are

- **2026-10-13 · F0 skeleton built, not committed yet.** Nine skills, eight references,
  three templates, two guards, README, LICENSE (MIT), CONTRIBUTING, CHANGELOG,
  `docs/DECISIONS.md`. Both guards exit 0 and fail on planted errors (positive control).
  `claude plugin validate .` passes. Its only warnings are about `CLAUDE.md` /
  `CLAUDE.local.md` at the root, which are maintainer files on purpose.
- **Remote:** `origin` = https://github.com/ru3enaa1/coderachnid.git. The repo is
  **public and empty**, so anything pushed is visible at once. Push only with the
  maintainer's go-ahead, and only after both guards pass.
- **Next:** the maintainer reviews the content, then the first commit and push, then F1.

## 3. Structure

```
.claude-plugin/plugin.json        manifest (name, version, description, author, license)
.claude-plugin/marketplace.json   makes the repo installable with /plugin marketplace add
skills/<name>/SKILL.md            one sense per folder; detail in references/
skills/project-setup/templates/   CLAUDE.template.md, DEVELOPMENT_PLAN.md, ADR.md
guards/                           scripts that verify (the third layer)
docs/DECISIONS.md                 why the plugin is shaped this way
```

The rules template is named `CLAUDE.template.md`, never `CLAUDE.md`: Claude Code loads
any `CLAUDE.md` it finds in a subfolder as live instructions.

## 4. Writing skills

- `name` equals the folder name: lowercase, hyphens, ASCII.
- **`description` decides activation.** Start with *when to use it* (concrete triggers),
  then what it adds. At least 80 characters.
- `SKILL.md` stays under 150 lines. Stack-specific detail goes in `references/<stack>.md`,
  linked from the skill.
- Lead every rule with the instruction, then the reason. Give each rule a check.
- After editing, run `bash guards/check-skills.sh` and confirm exit code 0.

## 5. Roadmap (phases, in order)

| Phase | Delivers | Done when |
|---|---|---|
| **F0 · Skeleton** | Manifest, marketplace, 9 skills, references, templates, guards, docs | Both guards exit 0; maintainer reviewed the content |
| **F1 · Local trial** | Plugin loaded with `claude --plugin-dir`, tried on a sample project | Each skill activates on its intended task and **not** on an unrelated one; findings recorded |
| **F2 · Evaluation** | Activation and compliance evals (the `skill-creator` skill has tooling) | Each skill measured; descriptions tuned |
| **F3 · Guard hardening** | Positive-control tests for both guards; adoptable project guards | Each guard fails on a known-bad fixture |
| **F4 · Publish v0.1.0** | Private GitHub repo → sanitizer review → public, tagged `v0.1.0` | Installs from GitHub on a clean machine |
| **F5 · Grow** | More stack references (Python, Node/TypeScript, PostgreSQL), optional hooks | Each addition follows CONTRIBUTING.md |

## 6. Commands

```sh
bash guards/check-skills.sh; echo $?          # skill shape and dangling references
bash guards/check-private-terms.sh; echo $?   # privacy (needs local .private-terms)
claude --plugin-dir "<path to this repo>"     # try the plugin without installing
claude plugin validate .                      # validate the manifests
```

Publishing (with the maintainer's explicit go-ahead; the repo is already public):

```sh
bash guards/check-skills.sh && bash guards/check-private-terms.sh   # both must exit 0
git push -u origin main
git tag v0.1.0 && git push origin --tags      # F4 only
```

The `claude` CLI is not on Git Bash's `PATH` on the maintainer's machine. It ships with
the VS Code extension (`.../anthropic.claude-code-*/resources/native-binary/claude.exe`).
`gh` is not installed.

## 7. Git

- Branch per phase (`feat/f1-local-trial`), conventional commits, merge to `main` with
  the maintainer's approval. Commit only when asked.
- Bump `version` in **both** manifests and move CHANGELOG entries on every release.

---

### How every response ends

Every response closes with the five-point block from the `response-closing` skill,
written in Spanish for the maintainer: **Siguiente fase · Claves del apartado ·
Puntos a tener en cuenta · Pruebas recomendadas · Implementación recomendada.**
