#!/usr/bin/env bash
# PostCompact: keep each compaction summary in .coderachnid/compact/, so what an automatic
# compaction kept is never lost and can be compared with the handoff. Keeps the last
# five. Always exits 0.
set -u
. "$(dirname "$0")/lib.sh" || exit 0
read_input

dir="$(project_dir)"
out="$dir/.coderachnid/compact"
mkdir -p "$out" 2> /dev/null || exit 0

# Extract the JSON string value of compact_summary (escaped quotes allowed inside),
# then undo the common escapes. Approximate on purpose: it is a record, not data.
summary="$(printf '%s' "$input" \
  | sed -n 's/.*"compact_summary" *: *"\(\([^"\\]\|\\.\)*\)".*/\1/p' \
  | sed 's/\\n/\
/g; s/\\t/	/g; s/\\"/"/g; s/\\\\/\\/g')"
[ -n "$summary" ] || exit 0

trigger="$(json_str trigger)"
file="$out/compact-$(date '+%Y%m%d-%H%M%S').md"
{
  echo "# Compaction summary ($(date '+%Y-%m-%d %H:%M'), ${trigger:-unknown} trigger)"
  echo
  printf '%s\n' "$summary"
} > "$file" 2> /dev/null

# Keep the five most recent summaries.
ls -1t "$out"/compact-*.md 2> /dev/null | tail -n +6 | while IFS= read -r old; do rm -f "$old"; done
exit 0
