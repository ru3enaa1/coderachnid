#!/usr/bin/env bash
# SessionStart (startup, clear, compact): reload the handoff that the coderachnid:handoff
# skill wrote, so a fresh session continues where the last one stopped instead of
# re-reading a long conversation. Prints nothing when there is no handoff.
# Always exits 0: a missing or unreadable file must never break the session.
set -u
. "$(dirname "$0")/lib.sh" || exit 0
read_input

dir="$(project_dir)"
handoff="$dir/.coderachnid/HANDOFF.md"

# A new context starts below every threshold: forget earlier size warnings.
rm -f "$dir/.coderachnid/.relay-warned" 2> /dev/null

[ -s "$handoff" ] || exit 0

max_lines="${CODERACHNID_RELAY_MAX_LINES:-150}"
written="$(date -r "$handoff" '+%Y-%m-%d %H:%M' 2> /dev/null || echo 'unknown date')"

echo "[coderachnid-relay] Handoff from an earlier session (.coderachnid/HANDOFF.md, written $written)."
echo "Continue from it without repeating it back to the user unless they ask. Check anything"
echo "not written today against the code before relying on it."
echo
head -n "$max_lines" "$handoff"
exit 0
