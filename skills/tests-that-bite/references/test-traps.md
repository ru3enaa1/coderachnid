# Test traps

Ways a test passes without proving anything, and the check for each. Each one cost real
time in a project before it became a rule.

## Tests that pass by luck

- **A negative case must be able to produce output if the filter breaks.** A mutation
  replaced "only confirmed items" with "all items" and nothing failed: the excluded test
  item had no data, so it produced nothing either way. Give it data that would trigger
  the rule if the filter let it through.
- **When the realistic fixture can't reach an edge** (ties, two candidates for one slot,
  a zero denominator, a dangling reference), hand-build one stored record with all the
  edges together and write one test per edge. Mutation survivors show which are missing.
- **Find items by identity, not by position.** When order comes from a computed score,
  "the first finding" changes as soon as the score does.
- **With the system clock, assert a date's shape; with a fixed clock, assert the date.**
  A test that pinned today's date failed the next morning.
- **Absence checks also scan embedded CSS and scripts.** "Doesn't contain `th:`" found
  `width:`. Match a precise pattern (` th:[a-z]+=`) or cut to the body first.

## Oracles: the obvious version checks the real one

When there are two ways to compute a result, one obvious and slow and one real, let the
first judge the second. The loop below is standard practice in competitive programming
and is **anticipated** here; comparing two builds of the same program is the form a real
project already confirmed (a trimmed runtime against the full one, byte for byte).

- **Write the brute-force version first** and check it against the examples worked by
  hand. If the oracle and the real version share a bug, they agree and prove nothing.
- **Generate many small random inputs.** Small ones reach the edges (empty, one, ties,
  duplicates) far more often than large ones, and a failure on five items can be read.
- **Seed the generator and print the seed** with every failure, so the case can be
  replayed. An unseeded generator finds a bug once and never again.
- **Stop at the first disagreement, shrink the input** until removing anything makes it
  pass, and keep that case as a named regression test.
- **Keep the comparison as a property test** (see the pyramid in `../SKILL.md`), with
  the oracle living in the test code, never in production.

## Mutation testing

- **Read each surviving mutant as a question:** is a test missing here? The first run's
  survivors pointed at real gaps (what enters a canonical input, comparison borders, a
  text looked up by position instead of type).
- **Keep a short list of known equivalent mutants** instead of chasing them. Example:
  removing `setRoundingMode(HALF_EVEN)` on a formatter whose default is already
  half-even changes nothing; keep the call, because it documents the rule.
- **Survivors on accessors nobody reads are a design smell, not a test gap.** Hold the
  finished value inside the draft instead of mirroring its fields.
- **Break the score down per class after each feature.** A 93% total for the project hid
  49% in a new reader. Hand-built edge cases raised the new code, on its own, above the
  bar.
- Mutation tools may run the tests in the build tool's runtime, not the toolchain's.
  Check which one when results differ from a normal run.

## Formats and determinism

- **Keep a format's writer and reader in one module**, with a round-trip test over real
  output and hundreds of randomized strings (quotes, backslashes, control characters,
  accents). A reader in another module, with another library, drifts.
- **Strict readers need fixtures in the real written shape.** Hand-written fixtures with
  missing fields stop loading once the reader is strict. That is correct: fix the fixture.
- **A determinism property must also permute the input order** (stored rows reversed and
  renumbered) and compare everything except storage ids. Repeating the same list proves
  nothing about tie-breaks.

## Checks over generated text

- **Run banned-phrase checks over generated output, not only templates.** A sentence
  built in code produced "100%", which sounds like a guarantee; the template tests never
  saw it. Walk the output model reflectively (every record and list) so a new field is
  covered without touching the test.
- **One banned-phrase list for the whole repository**, read by every module's tests and
  by the guard, so a phrase added once is enforced everywhere.
- **Text taken from data carries its own capital letter and final period.** Embedded in
  the middle of a sentence it gave "a The same role…" and "next..". Place it after a colon,
  strip its final period, and test the output for `..`. A name can also end in a period
  ("Corp."), so the helper that closes a sentence must not add a second one.
- **Run text checks over every sample case and the real data**, not only the unit
  fixture. The double period came from the third sample case, the only one whose company
  name ended in a period.
- **An explanation built in code states the real effect of each cause.** "Why the cap"
  also appeared for a cause that only delays. Each line takes its label from the effect
  stored in the data, and a test asserts the label per cause.
- **Tie text that quotes a fact to the source of that fact.** A screen named a backup file
  after the schema version and went stale with the next migration. A test now compares
  the text with the highest migration in the build.

## Checks over screens

- **A new automated check passes in a vacuum until its positive control.** A check for
  overlapping text said "all good" twice: it filtered on a width property its boxes never
  had. Prove each check by putting back the exact defect it targets: reverse-apply the
  fixing commit's change (`git diff <fix>~1 <fix> -- <file> | git apply -R`), see the
  check fail, then restore the file.
- **One defect, one check.** Overlapping text, a squashed scroll region, a primary action
  covered by another element, and a label clipped by its container's top edge are four
  different checks, and none of them sees the others. A panel that covers on purpose (a
  dismissible one) is not a collision: look for an element with a background on top.
- **A review script that falls back to an empty state reports green.** One resumed "the
  last record" only when a marker file existed; without it, it reviewed empty screens and
  said all good. Print the state reached first and read that line before the verdict.
- **Prepare state that lives only in server memory inside the same run** (an upload
  preview: upload the sample through the browser protocol). A one-use login link won't let
  a second script in.
- **A browser script's expected texts change with the screens' texts.** A journey test
  waiting for the old greeting failed after a copy change. Review those expectations with
  every change of screen text.
- **A tool that checks a placeholder view by its route stops checking it once that section
  is built.** When building a section, search the tools for its route and point them at a
  view that is still a placeholder.

## Tools and fixtures

- **Review tools close what they open and fail loudly.** A browser-driven check that
  closes only on success leaves child processes that lock the profile and break the next
  run with an unrelated error. Close through the browser's own protocol in a `finally`,
  and fail with the likely cause instead of hanging (for example, a one-time key already
  spent).
- **Share test fixtures across modules as a test artifact** (a test-jar or its
  equivalent) instead of copying them, so presentation tests run on real core output.
- **Native dialogs go behind a port.** File pickers and the file explorer are reached
  through an interface with a primary test double, or a test pops a window on the
  developer's screen.
- **Scripted terminal input: an empty line is "Enter".** Use comments, never blank
  lines, as visual separators in an answers script.
