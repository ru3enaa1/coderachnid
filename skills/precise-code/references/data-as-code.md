# Data as code

For rules, content and configuration that people write in YAML or JSON and the app
loads: knowledge bases, rule tables, questionnaires, pricing or threshold files. A typo
in them is a bug, so they get the same discipline as code.

## Shape

- **Closed structures, not expressions.** A condition is a data structure the code
  interprets (`{field: age, op: gte, value: 18}`), never a string the app evaluates.
  Expression evaluators on data are a security hole (see `security-first`).
- **Every file says what it is.** An identifier field matches the file name, so a copied
  file that kept the old identifier is caught.
- **One schema, written down,** next to the data, with an example of every field.

## Loading

- **Unknown key = error**, and the message lists the valid keys. A misspelled key is
  otherwise ignored in silence and its rule never applies.
- **Duplicate key = error.** Many parsers keep the last value without a word.
- **Report every problem at once**, each with file, path (`rules[3].when.value`) and a
  sentence the author understands. Fixing errors one run at a time wastes the author's day.
- **A terminal command validates the data** without starting the app, so authors can
  check their own edits.

## Format traps (one test each)

- YAML: an unquoted `: ` inside a sentence starts a new key; a comma inside an inline
  `{ }` or `[ ]` splits the text; in YAML 1.1 `no`, `yes`, `on`, `off` are booleans
  (YAML 1.2 treats them as text: know which one your parser speaks).
- Codes with leading zeros (`007`) become numbers unless quoted.
- Each trap gets a fixture that contains it and a test that the loader reports it.

## Reproducibility

- **Version plus content hash** for anything that produces a result from this data.
  Normalize line endings (Git on Windows converts LF to CRLF) and strip a BOM before
  hashing, or the same data hashes differently per machine.

## Testing the real content

- Besides fixtures, **load the project's real data in a test**. It may accept only an
  explicit list of known-pending problems, each tied to the step that resolves it. Any
  other problem fails the test.
- The list only shrinks. When it reaches zero, the test switches to "loads completely,
  zero problems", and stays there (see `tests-that-bite`).
