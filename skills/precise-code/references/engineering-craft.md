# Engineering craft: how well-known engineers work

Working habits that engineers with a long public record wrote down themselves, plus the
discipline of top competitive programmers, arranged along the build of a first version.

**What transfers is the method, not the style.** Contest code is one file with
one-letter names, macros and no tests, written to live two hours. A product is read for
years. Copy how those people think before they type and how they check afterwards;
never how their contest code looks.

Rules marked *(field)* had already been paid for in this plugin's own projects; the rest
are **anticipated** here: sourced from published work, not yet confirmed or corrected by
a real project of ours. Sources are listed at the end with what was checked.

## 1. Understand before typing

- **Restate the task with its inputs, outputs and limits, and work one example by
  hand.** In a contest the statement and its limits are read whole before any code; a
  misread statement costs more than slow typing ever does. *(field)* A formula copied
  from a specification was wrong, and one case worked by hand with units caught it.
  Check: the hand-worked example is the first test.
- **Let the limits choose the design.** Ten items allow trying everything; a hundred
  thousand need something close to linear. For a product the limits are: how many
  records, how many people at once, how fast the screen must answer, on which device.
  Without those numbers neither "simple" nor "scalable" can be decided, only argued.
  Check: the numbers are written in the requirements or the plan.
- **List the edge cases before coding**: empty, one, the maximum, duplicates, ties,
  zero, negative, out of order, the same request twice. They become the first tests.

## 2. Design: data first, then the simplest thing

- **Design around the data.** Decide what is stored, how the pieces relate and what must
  always be true of them. With the right structures the code turns out short and
  obvious; with the wrong ones no amount of code helps (Torvalds, 2006).
  Check: the entities and their invariants exist before the first function.
- **Aim for a design so simple that it obviously has no deficiencies**, not one so
  complicated that it has no obvious ones (Hoare, 1980).
- **Remove the special case by reshaping the problem.** When the first, last or empty
  case needs its own branch, look for a representation where it is the normal case
  (Torvalds, 2016, on deleting from a linked list). Check: count the `if`s that exist
  only for an edge; each one is a question about the data's shape.
- **Make modules deep:** a small interface over a lot of behavior. A module whose
  interface is as complicated as its body costs more than it hides. Where the meaning
  allows, define the error out of existence (deleting what is already gone succeeds);
  failures the caller must know about are still reported (Ousterhout, 2018).
- **Use brute force when the sizes allow it** (Lampson, 1983). The obvious version is
  easier to get right, and it stays useful afterwards as the oracle of section 4.

## 3. Build in small steps, each one run

- **Make the change easy, then make the easy change** (Beck). When a change is hard,
  first reshape the code so that it becomes easy, with behavior unchanged and tests
  green; then make it. Check: two commits, and the first changes no behavior.
- **One thing per step, run after each.** *(field)* Dependencies added one at a time
  left one suspect when something broke; the same holds for every edit.
- **Prefer functions that only read their arguments and return a value.** Purity is a
  matter of degree, and each step toward it removes hidden state to set up, mock or
  forget (Carmack, 2012). *(field)* Injecting the clock and the random seed is the same
  move.
- **Turn every automated check on from the first day**: compiler warnings as errors,
  static analysis, linters. They catch a class of mistakes every single time, which no
  reviewer does (Carmack, 2011). *(field)* A security analyzer added just before a
  release found eight things to fix at once, long after the commits that caused them.
- **A prototype built to learn is thrown away** (Lampson, 1983, after Brooks). Write it
  in a scratch folder, move what it taught into the plan, and never promote it.

## 4. Verify: a test is not a proof

- **Testing shows that bugs are present, never that they are absent** (Dijkstra, 1970).
  So stack different kinds of evidence: invariants checked in the code, tests, an
  oracle, and a look at the real thing running.
- **Stress the real version against the obvious one.** A standard habit in competitive
  programming: when a clever solution is in doubt, run it against a brute-force one on
  many small random inputs until they disagree or the doubt is gone. How to do it:
  `../../tests-that-bite/references/test-traps.md`
  (oracles). *(field)* A trimmed runtime was trusted only after its output matched the
  full one byte for byte.

## 5. Debug by narrowing

- **Reproduce first**, with a failing test *(field)*.
- **Halve the search** instead of guessing: half the input, half the code path, half the
  history (`git bisect`). Each step must answer "is the bug in this half?".
- **Shrink the failing input** until removing anything makes it pass. The smallest
  failing case usually names the bug.

## 6. Optimize last, with a measurement

- **Leave small efficiencies alone most of the time; find the few places that matter by
  measuring, then optimize those** (Knuth, 1974). Check: the commit carries the
  measurement before and after, and the simple version remains as the oracle.

## Sources

Checked on 2026-11-17. "Opened" means the text was read at the source; "confirmed"
means the attribution was cross-checked in secondary sources but the original was not
opened.

- Linus Torvalds, message to the git mailing list, 2006-07-27, on data structures
  (opened, in the LWN archive); TED interview, 2016, on "good taste" (confirmed).
- C. A. R. Hoare, "The Emperor's Old Clothes", Turing Award lecture 1980, CACM 1981
  (confirmed).
- John Ousterhout, *A Philosophy of Software Design*, 2018 (confirmed).
- Butler Lampson, "Hints for Computer System Design", 1983 (confirmed).
- Kent Beck, "make the change easy, then make the easy change", in his own newsletter
  (confirmed; first date not established).
- John Carmack, "Static Code Analysis", 2011, and "Functional Programming in C++", 2012
  (confirmed).
- Edsger W. Dijkstra, "Notes on Structured Programming" (EWD249), 1970 (confirmed).
- Donald Knuth, "Structured Programming with go to Statements", 1974 (confirmed).
- Stress testing against a brute-force solution: common practice in competitive
  programming, described in many community guides (confirmed). No method published by
  an individual champion was found, so none is attributed.
