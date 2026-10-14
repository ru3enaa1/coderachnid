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
