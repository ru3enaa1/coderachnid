#!/usr/bin/env bash
# Fails if any private term appears in a file that would be published.
#
# The terms live in `.private-terms` at the repository root: one per line,
# case-insensitive, lines starting with # ignored. That file is git-ignored on
# purpose: a list of what must not be published cannot itself be published.
#
# Scans every file git would publish (tracked + untracked, minus ignored).
# Outside a git repository it scans the working tree, minus the ignored local files.
# Exit code: 0 when clean, 1 when a term is found, 2 when nothing could be checked.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TERMS="$ROOT/.private-terms"

if [ ! -f "$TERMS" ]; then
  echo "missing $TERMS (one private term per line); nothing was checked"
  exit 2
fi

# Case-insensitivity is done by lowercasing both sides, not with `grep -i`:
# the GNU grep 3.0 shipped with Git for Windows aborts (exit 134) on `-i` with more
# than one pattern, and an aborted grep must never read as "no match".
# `tr` lowercases ASCII only, so write terms without accents where it matters.
lower() { tr '[:upper:]' '[:lower:]'; }
patterns="$(mktemp)"
trap 'rm -f "$patterns"' EXIT
grep -vE '^[[:space:]]*(#|$)' "$TERMS" | tr -d '\r' | lower > "$patterns"
if [ ! -s "$patterns" ]; then
  echo "$TERMS has no terms; nothing was checked"
  exit 2
fi

cd "$ROOT" || exit 2
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  files="$(git ls-files --cached --others --exclude-standard)"
else
  files="$(find . -type f ! -path './.git/*' ! -name '.private-terms' ! -name 'CLAUDE.local.md' | sed 's|^\./||')"
fi

found=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  # Line numbers survive lowercasing; the shown text is the lowercased line.
  out="$(lower < "$f" | grep -nF -f "$patterns")"
  status=$?
  if [ "$status" -eq 0 ]; then
    printf '%s\n' "$out" | sed "s|^|$f:|"
    found=1
  elif [ "$status" -gt 1 ]; then
    # grep exit 1 = no match; anything above is an error and must not pass silently.
    echo "error: grep failed with status $status on $f"
    exit 2
  fi
done <<< "$files"

if [ "$found" -eq 1 ]; then
  echo "private terms found (see above)"
  exit 1
fi
echo "clean: no private terms in publishable files"
