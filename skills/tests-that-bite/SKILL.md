---
name: tests-that-bite
description: Use whenever a bug is reported or fixed (reproduce it with a failing test before touching the code), and when writing or reviewing tests, adding a security control, or deciding whether work is done. Catches vacuous tests, tests that assert the bug, negative cases that fail for the wrong reason, masked exit codes and coverage that proves nothing, using positive controls, mutation testing, property tests and golden files.
---

# Tests that bite

A test that cannot fail protects nothing. Green coverage says a line *ran*; it does not
say a wrong line would be *noticed*.

## The rules

1. **Bugs are fixed red-first.** Write the test that reproduces the bug, watch it fail,
   then fix it. During an audit, *provoke* the error; never patch it before it is
   reproduced.
2. **Prove the test can fail (positive control).** Break the code or the input once on
   purpose and see the test go red. "Zero violations" means nothing until a known
   violation shows up in the same check.
3. **"No longer exists" tests can pass vacuously.** Assert that the thing *existed*
   before asserting that it is gone.
4. **A test can assert the bug.** When writing the expected value, read it as the end
   user would (`"Inc.."` with two dots is a bug, not a fixture).
5. **A negative case must fail for the right reason.** Assert the error code or
   message, not just that "something failed".
6. **Assert the property, not the number:** `before + 1`, not `3`.
7. **Thresholds are derived, never eyeballed.** The test uses the named constant, not a
   copied `0.05`.
8. **Create through the real flow.** Objects built by hand skip steps that production
   takes. Seed data must also obey the app's own rules.
9. **Read the HTML to check what the user sees; read the database to check what was
   saved.** Mixing the two gives false positives.
10. **Zero residue.** Each integration test uses its own temporary database or file.
    There is no shared database to dirty (see `safe-database`). Tests point the app's
    data folder inside the build output, never at the user's real one.
11. **Never edit a test to match broken behavior, and never delete one to get green.**
12. **A green build does not prove the app starts.** Start it and open it.

## The pyramid

- **Architecture tests**: forbidden dependencies, no `now()` or unseeded random in the core.
- **Unit tests**: rules and calculations, pure and fast.
- **Property tests** (jqwik, Hypothesis, fast-check): laws over thousands of inputs,
  such as ordering (`P10 ≤ P50 ≤ P90`), monotonicity, zero is absorbing, scaling and
  bounds.
- **Integration tests**: real database in a temp file or container, real migrations,
  real HTTP layer.
- **Golden files**: a sample input produces an expected output, compared byte for byte.
  Regenerated only by an explicit command, with the diff reviewed in the commit. Golden
  files are pinned to LF in `.gitattributes`.
- **End-to-end tests**: a few complete journeys in the real UI.

## Gates

- Coverage minimum: 80% overall, ~90% for the core.
- **Mutation testing** (PIT, Stryker, mutmut) on the core: at least 80% of mutants
  killed. It catches the `> 5` guard that lets through exactly the case it should stop.
- **Every security control has a test** (see `security-first`).
- **Forbidden-content tests** for product promises: a test scans every user-facing
  text for forbidden phrases (for example "guaranteed" or "risk-free"). The list lives in
  a file and grows with each review.
- **Every data/config file is loaded by a test** (YAML, JSON), with its schema
  validated. One unquoted `: ` breaks YAML.
- **Migrations are tested from every released version** (see `safe-database`).

## Definition of done

- [ ] The full build is green, **checked by the exit code**, not the console color.
- [ ] Every new rule has a test with a descriptive name.
- [ ] Coverage and mutation thresholds met.
- [ ] Changed data format: migration + previous-version sample + migration test.
- [ ] Changed output: golden files regenerated and the diff reviewed.
- [ ] Security checklist reviewed (see `security-first`).
- [ ] Seen working in the real app, in each theme and at each supported viewport.
- [ ] The app is left **stopped**.

Framework-specific testing traps: `../blind-spots/references/`.
