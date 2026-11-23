# adr-guard · the six audit lenses

Each lens reads every changed hunk, looks outside the diff where its question leads, and
marks its cells in the coverage ledger. Each finding names the lens, the file and line,
the evidence, and the decision clause it touches (if any).

## 1. Compliance with the ADR

- Every decision clause: run its check (`audit.md`, step 4) and record MET, PARTLY,
  VIOLATED or NOT VERIFIABLE.
- The scope fence: files outside *May change*, touches to *Must not change*.
- Constraints with numbers (response time, limits, volumes): measured, or NOT VERIFIABLE.
- Contradictions with other accepted ADRs, which the change may break without naming.

## 2. Correctness

- Does the code do what the task asked, read as the user of the feature would?
- Edge cases: empty, one, maximum, duplicates, ties, zero, negative, time zones and dates,
  rounding of money, the same request twice.
- Error paths: what happens when a dependency fails, times out or returns garbage; no
  empty `catch`, no error flattened into a generic message that hides the cause.
- **Can the new tests fail?** A test that asserts the current output, a mocked-away rule,
  an assertion that only checks "not null": each is a finding. Prove one test bites by
  breaking the code in the worktree (see `../../tests-that-bite/SKILL.md`).
- Traps AI-written code falls into, each checked by opening the code it relies on: a
  call to a function or option that doesn't exist; a test changed to match the bug;
  truncated code (`// rest unchanged`); a value copied from an example instead of the
  real configuration; a duplicated helper next to the one that already existed.

## 3. Security

Applies the rules of `../../security-first/SKILL.md` to the change:

- Trust boundaries the change crosses: input, files, imports, external responses, model
  output.
- **Authorization on every new or changed route and action:** can a user act on what
  isn't theirs? Prove it with a probe when in doubt.
- Validation at the boundary, with limits equal to the database constraints.
- Injection of any kind: queries built by concatenation, shell, templates, paths.
- Secrets in code, configuration, tests, fixtures or logs; personal data in logs.
- New dependencies: exact version, why it was needed, known vulnerabilities, license
  (see `../../security-first/references/supply-chain.md`).

## 4. Damage

- **Callers of every changed function, class, endpoint or table**, searched across the
  repository: do they still compile, still mean the same thing, still get what they
  expect?
- Contracts other systems consume: API shapes, events, file formats, error codes.
  Backward compatibility, or a versioned change with its migration path.
- **Data:** schema changes and data migrations follow backup, migrate, test, verify
  (`../../safe-database/SKILL.md`); nothing destroys data without a guard; old rows still
  read correctly in the new code.
- Configuration and environment: new settings have defaults, and missing ones fail
  loudly at startup instead of silently.
- Hot paths and resources: new queries in loops, unbounded reads, missing pagination.
- **Rollback:** can the change be undone as the ADR says? What can't be undone?

## 5. Direction

- Matches the codebase's patterns, naming and layering (`../../precise-code/SKILL.md`);
  a new pattern has a reason, and an ADR if it is architectural.
- No scope creep: nothing added that the task didn't ask for.
- No dead code, debug leftovers, commented-out blocks or TODOs that hide unfinished work.
- Is it the simplest version that meets the clauses? Complexity without a clause behind
  it is a finding.

## 6. Operations

- Logs and metrics that would let someone notice this failing in production, without
  personal data.
- Deploy order: migrations before code, feature flags, configuration that must exist
  first.
- Documentation updated where the behavior changed: README, API docs, runbooks.
- The traps of the stack in use (`../../blind-spots/SKILL.md` and its references).
