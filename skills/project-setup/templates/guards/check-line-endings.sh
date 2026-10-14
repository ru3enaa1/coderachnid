#!/usr/bin/env bash
# Fails if a byte-compared file is not pinned to LF or has CRLF on disk.
#
# Usage: check-line-endings.sh <pathspec>...      (for example '*.svg' 'tests/golden/**')
#
# Why: Git on Windows converts text files to CRLF on checkout (`core.autocrlf`,
# `text=auto`). Golden files and generated output compared byte for byte then fail on a
# fresh clone while passing on the machine that wrote them. The fix is
# `<pattern> text eol=lf` in .gitattributes; this guard proves it is there and holds.
#
# Checks every tracked or new (not ignored) file matching the pathspecs:
#   1. `git check-attr eol` says lf, so checkout can't convert it;
#   2. the file on disk has no carriage return.
#
# Exit code: 0 when every file passes, 1 when one fails, 2 when nothing could be checked
# (not a git repository, or no file matched). Check the code, not the text.
set -u

[ "$#" -ge 1 ] || { echo "usage: check-line-endings.sh <pathspec>..."; exit 2; }
git rev-parse --is-inside-work-tree > /dev/null 2>&1 \
  || { echo "not inside a git repository; nothing was checked"; exit 2; }

files="$(git ls-files --cached --others --exclude-standard -- "$@" | sort -u)"
[ -n "$files" ] || { echo "no file matches: $*; nothing was checked"; exit 2; }

failures=0
checked=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  checked=$((checked + 1))
  eol="$(git check-attr eol -- "$f" | sed 's/.*: eol: //')"
  if [ "$eol" != "lf" ]; then
    echo "FAIL  $f: not pinned to LF (add '<pattern> text eol=lf' to .gitattributes)"
    failures=$((failures + 1))
  fi
  # Count CRs with tr, not grep: Git for Windows' grep strips the CR at the end of each
  # line before matching, so `grep $'\r'` never finds CRLF there (found by this guard's
  # own positive control).
  if [ "$(tr -cd '\r' < "$f" | wc -c)" -gt 0 ]; then
    echo "FAIL  $f: has CRLF line endings on disk"
    failures=$((failures + 1))
  fi
done <<< "$files"

[ "$checked" -gt 0 ] || { echo "no regular file matched; nothing was checked"; exit 2; }
if [ "$failures" -gt 0 ]; then
  echo "$failures problem(s) in $checked file(s)"
  exit 1
fi
echo "ok: $checked file(s) pinned to LF and clean"
