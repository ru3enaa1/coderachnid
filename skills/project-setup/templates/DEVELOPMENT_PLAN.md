# <PROJECT> — development plan

> The working guide. Followed **in order**. Each phase says what unlocks it, what it
> delivers, how to know it is done and which traps await it.

## 0. How to use this document

- **Before a phase:** read its section, read the existing code, say what is missing and
  what will change, and agree on it before writing code.
- **After a phase:** run the definition of done, fill in its status (date, branch, test
  count) and update "Where we really are" in `CLAUDE.md`.

## 1. Goal and frozen scope

**Milestone:** <MVP definition>.
**In scope:** <phases>.
**Out of scope until the milestone:** <explicit list>.

## 2. Phases

### F0 · Foundations

- **Unlocked by:** nothing (first phase).
- **Delivers:** build with tests, architecture test, coverage gate, data layer with
  migrations, security baseline, `CLAUDE.md`.
- **Done when:** the full build exits 0; architecture and migration tests exist and pass.
- **Security:** <threats introduced and their controls>.
- **Pitfalls waiting:** <known traps for this stack>.
- **Status:** <YYYY-MM-DD · branch · N tests · verdict>.

### F1 · <Name>

- **Unlocked by:** F0 merged.
- **Delivers:** 
- **Done when:** 
- **Security:** 
- **Pitfalls waiting:** 
- **Status:** 

## 3. Definition of done (every phase)

- [ ] Full build green, confirmed by the exit code.
- [ ] Every new rule has a test; coverage and mutation thresholds met.
- [ ] Data format changed → migration + previous-version sample + migration test.
- [ ] Security checklist reviewed.
- [ ] Seen working in the real app.
- [ ] App left stopped.
- [ ] Branch merged with the human's approval.

## 4. After the milestone

<Field validation: who, how, what counts as success, what would stop the project.>

## 5. How every response ends

> **▸ Next phase** · **▸ Keys** · **▸ Watch-outs** · **▸ Recommended tests** · **▸ Recommended implementation**
