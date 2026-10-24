# Reproducible outputs

For products whose results must come out the same every time: simulations, reports,
generated documents or drawings compared byte for byte. "Same input, same code version,
same data, same bytes" only holds if every source of variation is pinned.

## Randomness

- **Ship your own generator.** A platform's seeded random is not part of its contract:
  a runtime upgrade can change the algorithm and old results stop reproducing. Use a
  published algorithm, test it against its **official test vector**, and ban the platform
  generator in the core with an architecture test, even when seeded. Give that rule a
  deliberate violation so the test is known to bite.
- **One stream per input datum, not per result.** Derive each stream from the seed and
  the datum's name. If every result draws its own copy of a shared input, the total mixes
  a good draw for one result with a bad draw for another; and adding a result shifts all
  the others.

## Canonical input

- **The seed or hash covers only what can change the output.** Leave labels, display
  names and record timestamps out, so renaming something or re-saving the same value
  changes nothing.
- **Test both directions:** "this change moves the seed" and "this change does not".

## Numbers

- **Round money once, at persistence**, to integer minor units with banker's rounding.
  Everything shown derives from the stored value.
- **A score that defines a level is stored unrounded and displayed truncated.** 74.6
  shown as "75" claims the next level.
- **One formatting rule for every surface** that shows the same number (scale, explicit
  locale, rounding mode). A screen and a report formatting on their own end up saying
  "3.4" and "3.35".
- **Parse amounts strictly.** `11.000` is eleven or eleven thousand depending on the
  locale; for money that is a thousandfold error. Reject thousands separators in input
  and ask for the plain number.

## Order and identity

- **Every tie-break ends on a stable key of the data**, never on insertion order or a
  storage id. Check it by permuting the input order (see `tests-that-bite`).
- **A value looked up by identity is built once and passed around.** Two equal records
  built separately are `equals` but not the same reference, so an identity map misses
  the second.

## Geometry and documents

- **Use the strict math library for geometry compared byte for byte.** Fast `sin` or
  `pow` may differ by one ulp across processors, and rounding does not always hide it.
- **Byte-identical PDFs need fixed metadata.** Set the document dates from the source
  data before rendering (the XMP block is built from them) and derive the document id
  from the data's hash. Test: two runs, the same bytes.
- **Dates in a generated document use the time zone stored with the data**, never the
  zone of the machine that renders it.
