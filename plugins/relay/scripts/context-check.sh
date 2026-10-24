#!/usr/bin/env bash
# UserPromptSubmit: when the conversation grows past a token threshold, ask Claude to
# update the handoff and recommend /clear. Every message re-reads the whole context,
# so a long conversation costs more on each turn.
#
# The size is read from the last API usage recorded in the transcript (input + cache
# creation + cache reads). Warns once when the threshold is crossed, then again every
# CODERACHNID_RELAY_STEP tokens. Always exits 0 and never blocks the prompt.
set -u
. "$(dirname "$0")/lib.sh" || exit 0
read_input

transcript="$(to_unix_path "$(json_str transcript_path)")"
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

usage="$(tail -n 400 "$transcript" 2> /dev/null | grep -o '"usage":{[^}]*' | tail -n 1)"
[ -n "$usage" ] || exit 0

field() { printf '%s' "$usage" | grep -o "\"$1\":[0-9]*" | head -n 1 | grep -o '[0-9]*$'; }
in="$(field input_tokens)"
created="$(field cache_creation_input_tokens)"
read_cache="$(field cache_read_input_tokens)"
tokens=$(( ${in:-0} + ${created:-0} + ${read_cache:-0} ))

threshold="${CODERACHNID_RELAY_TOKENS:-120000}"
step="${CODERACHNID_RELAY_STEP:-60000}"
[ "$tokens" -ge "$threshold" ] 2> /dev/null || exit 0

dir="$(project_dir)"
marker="$dir/.coderachnid/.relay-warned"
last="$(cat "$marker" 2> /dev/null | grep -o '^[0-9]*' || true)"
last="${last:-0}"
# Already warned for this size band: stay quiet until the next step.
if [ "$last" -gt 0 ] && [ "$tokens" -lt $(( last + step )) ]; then exit 0; fi
mkdir -p "$dir/.coderachnid" 2> /dev/null && printf '%s\n' "$tokens" > "$marker" 2> /dev/null

echo "[coderachnid-relay] This conversation holds about $tokens tokens (relay threshold:"
echo "$threshold), and every message re-reads all of it. After answering this message,"
echo "update .coderachnid/HANDOFF.md with the coderachnid:handoff skill, then tell the user in"
echo "one line to type /clear: the next session reloads the handoff automatically."
exit 0
