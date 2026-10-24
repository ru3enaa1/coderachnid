---
name: handoff
description: Use when a conversation has grown long, when a relay hook reports its size, or when the user wants to continue in a fresh session without losing the thread. Writes a short handoff file (task, decisions, files, next step, open questions) so /clear costs almost nothing and the next session picks up exactly where this one stopped.
---

# Handoff

Every message re-reads the whole conversation. A long one costs more on each turn, and
resuming it after a pause can re-send all of it at full price once the prompt cache has
expired. A handoff keeps the thread in a few hundred words, so the conversation can be
cleared and the work continues.

## Write `.coderachnid/HANDOFF.md`

Overwrite it, never append: it describes now, not history. At most about 60 lines.

```markdown
# Handoff · <date and time>

## Task
What we are doing and why, in two or three lines. The phase or sub-step, if the project
has a plan.

## Done in this session
- What changed, with the file paths. What was verified, and how.

## Decisions
- Each decision made today and its reason. Who decided.

## Next step
The single next action, concrete enough to start without asking.

## Open
- Questions, risks or pending decisions, and whose decision each one is.

## Verify
- The commands that show the current state (tests, build, run), copy-pasteable.
```

## Rules

- **Facts, not transcript.** No code dumps, no full logs, no pasted conversation. Point
  to files and lines instead.
- **Durable decisions also go where they live**: the project rules file ("where we
  really are") and the plan. The handoff is short-term memory; it gets overwritten.
- **Never write secrets, credentials or personal data** in it.
- **Keep it out of version control**: it holds work in progress. If `.coderachnid/` is
  not in `.gitignore` yet, recommend adding it (one line) and let the user approve.
- **Why `.coderachnid/` and not `.claude/`:** Claude Code treats `.claude/` as sensitive
  and asks permission for every write there, which would interrupt each handoff.

## Then

Tell the user in one line to type `/clear`. With the `coderachnid-relay` plugin
installed, the next session loads the handoff by itself. Without it, the first message
of the new session is: "read .coderachnid/HANDOFF.md and continue".

## Habits that save more than any file

- **One conversation per task or sub-step.** Start the next one from the handoff.
- **Don't resume a long conversation after a pause**: its cache has probably expired
  and the whole conversation is re-sent. Write a handoff, or start fresh from the last
  one.
