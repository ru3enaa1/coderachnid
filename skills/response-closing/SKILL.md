---
name: response-closing
description: Use for every development task (writing or changing code, tests, configuration, data or plans): load it when the task starts, and end the final reply with a five-point block covering next phase, keys, watch-outs, recommended tests and recommended implementation, so the human always knows where the work stands and what to do next. Skip it for quick factual answers.
---

# Response closing

Every development response ends with the same five-point block. It turns a conversation
into a workflow: the human can read only the block and still know where things stand.

## The block

> **▸ Next phase:** which phase or step comes next, and what unlocks it.
> **▸ Keys:** what must not be lost from sight in the current work.
> **▸ Watch-outs:** risks, dependencies or decisions still pending (and whose decision each one is).
> **▸ Recommended tests:** what to test, how, and the exact command.
> **▸ Recommended implementation:** the single next concrete step.

## How to write it

- **Short and concrete.** One to three lines per point. No padding, no repetition of the
  response above it.
- **Real commands**, copy-pasteable, for the user's actual shell.
- **Honest status.** If something was skipped, failed or not verified, say so here in
  plain words. Never imply that it passed.
- **One next step**, not a menu. If a decision belongs to the human, name it as a
  watch-out and recommend an option.
- **Write in the user's language.** The labels may be translated, but their order stays
  the same.

## When to skip it

Skip it only for replies that are not development work (a quick factual answer, a
greeting), or when the project's rules say otherwise.

## Make it reliable

**Put the closing rule in the project rules file.** Skills are chosen per task, so this
one loads on some development replies and not on others (measured in F2). A line in
`CLAUDE.md` is read on every turn. `project-setup` adds that line; this skill holds the
format it points to.

## Example

> **▸ Next phase:** F2, the import pipeline. It is unlocked by merging F1 into `main`.
> **▸ Keys:** every imported value carries its provenance (measured / declared / reference).
> **▸ Watch-outs:** the CSV encoding of the sample files is unconfirmed. You decide: reject or auto-detect.
> **▸ Recommended tests:** `./mvnw verify; echo $?`, which should print 0, plus the new `ImportCsvTest`.
> **▸ Recommended implementation:** write the failing test for a semicolon-separated CSV first.
