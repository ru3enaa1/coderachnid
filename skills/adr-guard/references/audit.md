# adr-guard · audit mode

After the code is written: check, with evidence, that it does what the ADR decided,
that it breaks nothing, that it is secure, and that it goes the right way. Run it in a
fresh session, never the one that wrote the code.

## Principles

- **The implementer's word is not evidence.** "I tested it", "all tests pass", a commit
  message, a pull-request description: each is a claim to verify, not a finding.
- **Read-only on the code under review.** The audit reports; it does not fix. Probes and
  planted defects go in a separate worktree (step 6), never in the user's working tree.
- **Evidence for every line, passes included:** file and line, command with its exit
  code, or test name. "Found nothing" is not a pass; a pass shows what was looked at.
- **No sampling.** Every changed hunk is read by every lens. If the change is too big to
  read hunk by hunk in one session, split it (by ADR, then by module) and audit each
  part; never review a subset and extrapolate.
- **The coverage ledger has no empty cell.** An empty cell is a gap, a gap is reported,
  and a report with gaps can't APPROVE.

## 1. Fix what is under review

- **The contract:** the ADR ids given, or the ADRs that cover the changed paths. No ADR
  for the change → stop and recommend `/coderachnid:adr-guard plan` (a retroactive ADR).
  An ADR still *proposed* → say so: the code was built on an unaccepted decision.
- **The change:** `git diff <base>...HEAD` (the base from the arguments, else the
  baseline file, else ask). If the user gave a saved diff file instead of a ref, read it
  and say that the history could not be checked. List every file and every hunk with a
  number: the ledger's rows.
- **Uncommitted changes** (`git status`): name them. Audit the committed change unless
  the user says otherwise, and say which.
- **Scope fence:** every changed file outside *May change*, and every touch to *Must not
  change*, is a finding before anything else is read.

## 2. Reproduce

Run what the baseline ran, the same way; read the real exit codes (a pipe or a red
console line can hide them):

- build, full test suite, linters, static analysis;
- the application's start, when the change can affect it;
- **compare with the baseline:** a test failing now and passing then is a regression
  (BLOCKER); one failing in both is old, noted but not blamed on this change; one that
  disappeared is a finding until explained.

If a command can't run here, the clauses that depend on it are NOT VERIFIABLE and the
report says why.

## 3. Read the change through six lenses

The lenses and what each runs and reads: `audit-lenses.md`. Rules:

- **Each lens reads every hunk** and marks its cells in the ledger.
- **When subagents are available, run each lens in its own**, with a clean context, the
  ADR, the diff, the baseline and these rules; then merge their findings and ledgers.
  Without them, run the lenses one after the other and re-read the diff for each.
- **Each lens looks outside the diff where its question leads:** callers of a changed
  function, the migration history, the configuration that reads a new setting.

## 4. Run each clause's check

For every decision clause: run the check written in the ADR, as written. Record
MET (the check passed, with its evidence), PARTLY, VIOLATED, or NOT VERIFIABLE (with the
reason). A check that passes for the wrong reason (it never exercised the rule) is not
MET: prove it can fail (step 6).

## 5. The adversarial pass

For each risky path the tests don't cover, and each suspected defect: try to break it.
Empty, maximal and duplicated input; a user acting on something that isn't theirs;
the same request twice at once; the dependency failing or timing out; old data in the new
code. **Prove a defect with a failing probe test** in the worktree of step 6. What can't
be proven stays labelled *suspected*, with what would prove it.

## 6. The worktree for probes and planted defects

Never touch the user's working tree. Create a disposable copy of the reviewed commit:

```sh
git worktree add "<temp folder>/adr-guard-NNNN" HEAD
# probes and planted defects live here
git worktree remove --force "<temp folder>/adr-guard-NNNN"
```

**Positive control of the review**, required when any critical clause or a security
trigger is involved: in the worktree, plant the defect the review should catch (remove
an authorization check, make a migration drop a column, break a decision clause) and run
the checks and lenses that should see it. If none does, the review is not trusted: say
so, and say which check failed to bite. Remove the worktree at the end and confirm the
user's tree is unchanged (`git status` the same as at the start).

## 7. Decide the verdict

Severities and the report: `review-report.md`.

- **BLOCK** when any of: a BLOCKER finding; a VIOLATED clause; a regression against the
  baseline; the positive control was not caught.
- **INCONCLUSIVE** when nothing blocks but a critical clause, or the comparison with the
  baseline, could not be verified (no shell, a missing service, no credentials). "I could
  not check it" is never reported as "it is fine": the report lists exactly what to run,
  and the change is not delivered until it has run.
- **APPROVE WITH CONDITIONS** when there are MAJOR findings or non-critical clauses NOT
  VERIFIABLE, each condition named with who must do what.
- **APPROVE** only with every clause MET, no BLOCKER or MAJOR finding, and no empty cell
  in the ledger.

The verdict follows these rules mechanically. If the evidence and your judgment
disagree, the report says so; the verdict still follows the rules.

## 8. Report and hand back

- Write `docs/reviews/ADR-NNNN-audit-<date>.md` from the template, with the head commit
  inside.
- **The final reply repeats the one-screen summary:** verdict, findings by severity with
  file and line, clauses not MET, regressions, what was not verified.
- **Drift:** when the code departs from the ADR for a reason that looks right, propose
  the amendment (a new ADR that supersedes the clause) for the human to decide. The
  verdict still treats the clause as VIOLATED until the human accepts the change.
- Ask before committing the report in an organization's repository.
