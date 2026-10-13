#!/usr/bin/env bash
# Creates the throwaway project the activation trial runs against.
#
# Usage: bash evals/activation/setup-sandbox.sh <new-empty-dir>
#
# The sample is a tiny notes API (Python standard library + SQLite) with a few realistic
# flaws left in on purpose, so the skills have something to notice. The flaws are
# listed in docs/F1-TRIAL.md, never in the sample itself: a comment would give them away.
# Keep the directory outside this repository: run.sh resets it with git before every
# prompt.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:?usage: setup-sandbox.sh <new-empty-dir>}"

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  echo "$DEST exists and is not empty; choose a new directory"
  exit 2
fi
mkdir -p "$DEST"
cp -R "$HERE/sandbox/." "$DEST/"
git -C "$DEST" init -q
git -C "$DEST" add -A
git -C "$DEST" -c user.name=sandbox -c user.email=sandbox@example.invalid commit -qm "sample notes app"
echo "sandbox ready: $DEST"
