# <PROJECT> — project rules

<One paragraph: what this project is, who it is for, and what it must never become.>

---

## 1. Non-negotiables

<!-- Each rule is a fact the code and tests can check. Keep only what truly never bends. -->
- **Security first:** <the boundary that matters most, e.g. "the server listens only on 127.0.0.1">.
- **Secrets** live only in environment variables or the OS keychain.
- **<Data rule>:** <e.g. "no personal data in logs", "health data never stored">.
- **Reproducible:** same input + same version = same output.
- **Scope is frozen** until <milestone> (see `DEVELOPMENT_PLAN.md`).

## 2. Where we really are

<Current phase, what is closed (with date and branch), what is next. Update when each phase closes.>

## 3. Product rules that govern the code

1. <Rule>

## 4. Architecture

<Modules and their allowed dependencies. Which architecture test enforces them.>

## 5. Stack

<Language and version, framework, database, test tools. Exact versions live in docs.>
Dependencies enter one at a time, in the phase that needs them, with the version verified that day.

## 6. Code conventions

- Read before changing; for larger changes, say what will change first.
- Comments explain why. Named constants carry their reason.
- Functions < 50 lines, files < 400, nesting ≤ 4.
- Never mark as done something that did not compile and was not tested.

## 7. Database

- Backup → migrate → test → verify. Tests run against disposable databases, never the original.
- Forward-only migrations. Test rows are deleted by id.

## 8. Pitfalls

<!-- Recorded with the pitfall-log format: rule, symptom, cause, check, date. -->
**Environment:**
- 

**Build and framework:**
- 

**Tests:**
- 

## 9. Commands

```sh
<build and test command>; echo $?   # real exit code
<run the app in development>
<stop the app: by PID or port, never by process name>
```

## 10. Where everything else is

| File | What it holds |
|---|---|
| `DEVELOPMENT_PLAN.md` | The phases, in order, and their status |
| `docs/adr/` | Architecture decisions |

---

### How every response ends

Every development response closes with the five-point block: next phase · keys ·
watch-outs · recommended tests · recommended implementation.
