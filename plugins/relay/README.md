# coderachnid-relay

Opt-in hooks that keep long Claude Code sessions light. They work with the `handoff`
skill of [coderachnid](../../README.md).

Every message re-reads the whole conversation, so a long one costs more on each turn,
and resuming it after a pause can re-send all of it once the prompt cache has expired.
The relay keeps the thread in a short file instead:

1. When the conversation passes a token threshold, a hook asks Claude to write
   `.coderachnid/HANDOFF.md` and to tell you to type `/clear`.
2. You type `/clear`. That is the one manual step: hooks cannot clear a session.
3. The new session starts with the handoff loaded, a few hundred words instead of the
   whole conversation, and continues where the last one stopped.

## Install

```
/plugin marketplace add ru3enaa1/coderachnid
/plugin install coderachnid@coderachnid
/plugin install coderachnid-relay@coderachnid
```

The relay needs coderachnid for the `handoff` skill. It runs plain `bash`, `grep`, `sed`
and `tail` (Git Bash on Windows): no jq, Python or Node.

Add `.coderachnid/` to the project's `.gitignore`: it holds work in progress.

## What each hook does

| Hook | When | What it does |
|---|---|---|
| `SessionStart` | New session, after `/clear`, after compaction | Loads `.coderachnid/HANDOFF.md` into the session, if it exists |
| `SessionStart` | Resuming a conversation | Warns when it re-sends many tokens with an expired prompt cache, and offers a handoff |
| `UserPromptSubmit` | Every message | Past the threshold, asks for a handoff and a `/clear`; again every step after that |
| `PostCompact` | After any compaction | Saves the compaction summary in `.coderachnid/compact/` (the last five) |

Every hook exits 0 and prints nothing when it has nothing to say: a missing file never
breaks a session.

## Settings

Environment variables, all optional:

| Variable | Default | Meaning |
|---|---|---|
| `CODERACHNID_RELAY_TOKENS` | `120000` | Tokens in context before the first handoff request |
| `CODERACHNID_RELAY_STEP` | `60000` | Tokens between later reminders |
| `CODERACHNID_RELAY_RESUME_TOKENS` | `100000` | Size from which a resume with an expired cache is flagged |
| `CODERACHNID_RELAY_MAX_LINES` | `150` | Lines of the handoff loaded into a new session |

## Status line (optional)

`statusline.sh` shows the tokens in context and, on Pro and Max plans, how much of the
five-hour usage limit is spent:

```
ctx 182k/1000k (18%) · 5h 41%
```

Copy it to `~/.claude/coderachnid-statusline.sh` and add to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "bash ~/.claude/coderachnid-statusline.sh" }
```

## Checked

`guards/tests/test-guards.sh` covers every hook and the status line with planted inputs,
including escaped Windows paths. In a real session on Windows, a new session answered
with a codeword that existed only in the handoff, and a resumed session past the
threshold wrote the handoff and asked for `/clear`.
