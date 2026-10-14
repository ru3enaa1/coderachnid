#!/usr/bin/env bash
# Fails if any forbidden phrase appears in user-facing text.
#
# Usage: check-forbidden-phrases.sh <phrases-file> <path>...
#
# Why: a product that must never promise what it can't prove ("guaranteed", "risk-free",
# "100% accurate") needs a check, not a reminder. The list lives in a file and grows with
# every review that finds a new phrase.
#
# The phrases file has one phrase per line, matched case-insensitively as plain text.
# Lines starting with # and blank lines are ignored. Paths are scanned recursively;
# binary files are skipped.
#
# Exit code: 0 when clean, 1 when a phrase is found, 2 when nothing could be checked
# (missing list, empty list, missing path, or a grep error). Check the code, not the text.
set -u

list="${1:-}"
[ -n "$list" ] && [ "$#" -ge 2 ] || { echo "usage: check-forbidden-phrases.sh <phrases-file> <path>..."; exit 2; }
shift
[ -f "$list" ] || { echo "missing phrases file: $list; nothing was checked"; exit 2; }

# Case-insensitivity by lowercasing both sides, not `grep -i`: some grep builds (GNU grep
# 3.0 in Git for Windows) abort on `-i` with several patterns, and an aborted grep must
# never read as "no match". `tr` lowercases ASCII only.
lower() { tr '[:upper:]' '[:lower:]'; }
patterns="$(mktemp)"
trap 'rm -f "$patterns"' EXIT
grep -vE '^[[:space:]]*(#|$)' "$list" | tr -d '\r' | lower > "$patterns"
[ -s "$patterns" ] || { echo "$list has no phrases; nothing was checked"; exit 2; }

found=0
scanned=0
for path in "$@"; do
  [ -e "$path" ] || { echo "missing path: $path; nothing was checked"; exit 2; }
  while IFS= read -r -d '' f; do
    grep -Iq . "$f" 2>/dev/null || continue   # binary or empty
    scanned=$((scanned + 1))
    out="$(lower < "$f" | grep -nF -f "$patterns")"
    status=$?
    if [ "$status" -eq 0 ]; then
      printf '%s\n' "$out" | sed "s|^|$f:|"
      found=1
    elif [ "$status" -gt 1 ]; then
      echo "error: grep failed with status $status on $f"
      exit 2
    fi
  done < <(find "$path" -type f -print0)
done

[ "$scanned" -gt 0 ] || { echo "no text files under the given paths; nothing was checked"; exit 2; }
if [ "$found" -eq 1 ]; then
  echo "forbidden phrases found (see above)"
  exit 1
fi
echo "clean: no forbidden phrases in $scanned file(s)"
