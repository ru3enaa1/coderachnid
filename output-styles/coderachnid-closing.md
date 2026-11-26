---
name: closing
description: Claude Code's default behavior, plus a five-point closing on every development reply.
keep-coding-instructions: true
---

Keep your usual tone, length and way of working. This style changes only how a
development reply ends.

## Five-point closing

End every reply that involves development work (code, tests, configuration, data,
plans or reviews) with this block, after everything else:

**Next phase:** which phase or step comes next, and what unlocks it.
**Keys:** what must not be lost from sight in the current work.
**Watch-outs:** risks, dependencies or pending decisions, and whose decision each one is.
**Recommended tests:** what to test, how, and the exact command.
**Recommended implementation:** the single next concrete step.

- One to three lines per point. Don't repeat the reply above the block.
- Real commands, copy-pasteable, for the user's actual shell.
- Honest status: say plainly what was skipped, failed or not verified.
- Write in the user's language. Translate the labels and keep their order; if the
  project's rules name the labels, use those names.
- Skip the block for replies that are not development work: a quick factual answer, a
  greeting, or a clarifying question.

## When a change needs a deep review

The triggers: authentication or permissions, money, personal data, a database schema or
migration, a contract other systems use, security settings, or code that goes to an
organization or a client. When you **hand back** a change under one of them (its code is
written and the reply returns it to the user to test, review or commit) and no audit of
it is recorded in `docs/reviews/`, the **Recommended implementation** is this block,
filled in, and nothing else. Don't wait for the tests to pass or promise the block for
later: *Recommended tests* already says to run them first.

```text
adr-guard · NEEDED · audit
Why: <the trigger, with the file and line that show it>
Scope: ADR-<id> · <base commit>..<head commit> · <n> files
Run in a new session: /coderachnid:adr-guard audit <id> <base commit>
Bring back: the "adr-guard result" block that session prints at the end
```

- No ADR covers the change: the first line says `plan, then audit`, and *Run* numbers
  both commands; the plan's quoted task carries the acceptance criteria and the paths,
  because the new session knows nothing of this conversation.
- The command is complete: real ids and commits, never placeholders. A value that can't
  be read (no git yet) doesn't cancel the block: write what is known and, in its place,
  the one step that produces it. Keys stay in English as written; values in the user's
  language.
- **Say it once.** While you are still building the change, nothing. After the block was
  given, not again for later steps of the same change unless code under a new trigger was
  added; once more only when the user says the code is going out (merge, release,
  delivery) and no result block came back. No trigger shown by a file or a line: nothing.
- Before coding a risky task that no accepted ADR covers, the block recommends `plan`
  instead, once.
- When the user pastes a block that starts with `adr-guard result`, or asks whether a task
  needs a review, use the `adr-guard` skill.
