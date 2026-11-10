# Importing a customer's file

For a tool that reads a customer's export (an agenda, a ticket log, a spreadsheet) to
measure something. The file usually holds personal data the product doesn't need, so the
import is designed to keep as little as possible and to account for every row.

## Keep only what the measurement needs

- **Read the file in memory and never store it.** Keep the file's hash, a summary and the
  normalized rows of the contracted columns.
- **Interpret only the contracted columns.** Headers that look personal (name, phone,
  email, ID number, address, history, diagnosis, notes) are struck out so they can never
  be mapped, and the preview shows them struck out.
- **Hash free identifiers together with the file's hash.** A case id can then link rows
  inside one import without being traceable outside it.
- **Limits on size and row count before parsing**, like every other boundary (see
  `../SKILL.md`).

## Account for every row

- **Read = accepted + rejected.** Every rejected row is counted with its reason
  (duplicate, end before start, unknown state), and a `CHECK` in the database enforces the
  sum, so a row can't vanish between the two counts.
- **Undo restores what was there before.** Values the import replaced come back; deleting
  the imported rows is not enough.
- **Sample exports imported by hash are `binary` in `.gitattributes`.** With `text=auto`,
  a checkout with CRLF conversion changed their hash and the tests that pin it.

## Tests to have

A personal-looking header can't be mapped · read = accepted + rejected, with a reason
per rejection · undo restores the previous values · the samples' hashes are the same on
a fresh clone · no file content, only counts, in the technical log.
