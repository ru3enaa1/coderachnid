---
name: blind-spots
description: Use when editing or reviewing CSS or page layout (an element covering another, spacing, fixed or sticky parts), server templates (Thymeleaf, HTMX), generated documents or PDFs, build files or shell scripts; before saying work is done, ready, safe to ship, merge or release, or that it looks right; when copying code between projects or library versions, running build or shell commands, killing processes, taking screenshots or trusting a self-reported metric. Lists the blind spots AI coding agents repeatedly fall into and the concrete check that exposes each one.
---

# Blind spots

An agent can see the code but miss the things around it. Each row below is a mistake
that has actually happened, and the check that would have caught it. When a row applies,
**run the check. Don't reason about it.**

## Evidence

| Blind spot | Check |
|---|---|
| "It compiles", so it is done | Run the tests, start the app, see the change working |
| Exit code masked by a pipe (`cmd \| tail`) or by red stderr text in PowerShell | Read the real exit code (`$?`, `$LASTEXITCODE`) of the build command itself |
| "Zero errors / zero violations" from a check that captured nothing | Positive control: a known violation must appear in the same check |
| A metric estimated instead of measured (contrast, performance, size) | Measure it with a tool or a test; never copy a self-reported number |
| A test edited to match the bug, or deleted to get green | Never. Fix the code, or explain why the test was wrong |
| All tests and automated layout checks green, so it "looks right" | Look at screenshots at the user's real sizes, and at generated art at 3×, before closing |

## Assumptions

| Blind spot | Check |
|---|---|
| An API, column or file assumed to exist | Open it. Search for it. Read its tests |
| Code copied from another project or library version | Check the version in use. Packages get renamed between majors |
| A dependency added "at latest" | Pin an exact version, verified that day, added in the phase that needs it |
| A mockup or example that breaks a project rule | The rule wins. Say so explicitly |
| A formula taken from a spec document | Work one case by hand, with units, before coding it: a spec can be wrong |
| Long session: rules remembered loosely | Re-read the plan and the project rules before each new phase |

## Environment

| Blind spot | Check |
|---|---|
| Killing a process by name (`taskkill /IM java.exe`, `pkill node`) kills other apps | Stop by PID or by listening port only |
| Clean or rebuild while the app runs from that build output | Stop the app first |
| App left running at the end of the session | Stop it and confirm the port is free |
| Unquoted paths with spaces (home folders often have them) | Quote every path in scripts and JVM/test arguments |
| Environment variables set after the shell was opened | Read them from the source (registry, profile) or open a new shell |
| Shell mangling: heredocs and `sed` eat backslashes, path conversion rewrites `=/` | Write code and regexes with a file tool, not the shell |
| Git converts line endings on checkout | Pin byte-compared files to LF in `.gitattributes`, and test on a fresh clone |
| Locale, time zone or display scaling differ from yours | Set them explicitly. Check the viewport at the user's real scaled size |

## Output the user sees

| Blind spot | Check |
|---|---|
| Template comments shipped to the browser | Never write in a comment what the page must not say |
| Screenshot at a size the browser can't render (desktop windows have a minimum width) | Emulate the device. Check at the real scaled viewport (1920×1080 at 125% is 1536×737) |
| Accents encoded as entities in attributes | Compare with what the engine really emits, or use a regex |
| YAML that loads but means something else: an unquoted `: ` in a sentence, a comma inside `{ }` or `[ ]`, `no`/`yes` read as booleans (YAML 1.1), a duplicate key silently overwriting | A test loads every data file with a loader that rejects duplicate keys |

## Stack references (load only the one you need)

- `references/windows-shell.md`: PowerShell, Git Bash, Python and Node on Windows.
- `references/java-spring.md`: Maven, Spring Boot, MVC testing, Jackson.
- `references/server-templates-htmx.md`: Thymeleaf-style templates and HTMX.
- `references/web-frontend.md`: CSS, browsers, headless capture, clipboard, generated art.
- `references/documents-and-pdf.md`: reports rendered to screen and PDF, fonts, PDF/UA.

When you find a new blind spot, record it with `pitfall-log`.
