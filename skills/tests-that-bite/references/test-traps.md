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

## Mutation testing

- **Read each surviving mutant as a question:** is a test missing here? The first run's
  survivors pointed at real gaps (what enters a canonical input, comparison borders, a
  text looked up by position instead of type).
- **Keep a short list of known equivalent mutants** instead of chasing them. Example:
  removing `setRoundingMode(HALF_EVEN)` on a formatter whose default is already
  half-even changes nothing; keep the call, because it documents the rule.
- **Survivors on accessors nobody reads are a design smell, not a test gap.** Hold the
  finished value inside the draft instead of mirroring its fields.
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

## Tools and fixtures

- **Review tools close what they open and fail loudly.** A browser-driven check that
  closes only on success leaves child processes that lock the profile and break the next
  run with an unrelated error. Close through the browser's own protocol in a `finally`,
  and fail with the likely cause instead of hanging (for example, a one-time key already
  spent).
- **Share test fixtures across modules as a test artifact** (a test-jar or its
  equivalent) instead of copying them, so presentation tests run on real core output.
- **Scripted terminal input: an empty line is "Enter".** Use comments, never blank
  lines, as visual separators in an answers script.
