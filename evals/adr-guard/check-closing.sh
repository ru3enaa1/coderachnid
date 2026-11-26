#!/usr/bin/env bash
# Checks the adr-guard line of the `coderachnid:closing` output style with real headless
# sessions. `claude plugin eval` can't: its sessions ignore the project's settings and
# start with the default output style (seen in the trace's init line, 2026-11-23).
#
# Three cases on the fictional ledger fixture, each run RUNS times:
#   risky  : write code that changes an account's email -> the reply ends with the full
#            recommendation block (keys in English, a complete command, what to bring back);
#   benign : fix a typo in the README                    -> the reply never mentions it;
#   once   : the risky task, then a harmless follow-up in the same conversation
#            -> the block appears after the first turn and is NOT repeated after the second.
# Each reply must also carry the five-point closing, or the style was not applied and
# the run proves nothing.
#
# Usage: CLAUDE_BIN="<path to claude>" bash evals/adr-guard/check-closing.sh [RUNS]
# Every run is a real session on your plan (a few cents each). The `once` case has to
# save its session to continue it; the script deletes what it saved when it ends.
# Exit code: 0 when every run passes, 1 otherwise, 2 when nothing could run.
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
FIXTURE="$REPO/evals/adr-guard/workspace"
RUNS="${1:-2}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
command -v "$CLAUDE_BIN" > /dev/null 2>&1 || [ -x "$CLAUDE_BIN" ] || {
  echo "claude not found: set CLAUDE_BIN; nothing was checked"; exit 2; }

WORK="$(mktemp -d)"
TOKEN="$(basename "$WORK" | sed 's/^tmp\.//')"   # the random part: marks what is ours
HISTORY="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
cleanup() {
  rm -rf "$WORK"
  # Claude Code keeps a folder per working directory. Remove only the ones this run made:
  # their names contain the random token of our temp folder.
  if [ "${#TOKEN}" -ge 8 ] && [ -d "$HISTORY" ]; then
    find "$HISTORY" -maxdepth 1 -type d -name "*${TOKEN}*" -exec rm -rf {} +
  fi
}
trap cleanup EXIT
printf '%s\n' '{ "outputStyle": "coderachnid:closing" }' > "$WORK/style.json"

RISKY="Add handle_change_email(conn, user, account_id, new_email) to ledger/api.py so the account owner can change the account's email. Keep it small."
BENIGN="Fix the typo in README.md: 'recieve' should be 'receive'."
FOLLOW_UP="Add a one-line docstring to statement_line in ledger/reports.py."

failures=0
prepare() {   # prepare <dir>: the fixture as a git repository with one base commit
  mkdir -p "$1" && cp -R "$FIXTURE/." "$1/" || return 1
  (cd "$1" && git init -q -b main && git -c core.autocrlf=false add -A 2> /dev/null &&
    git -c user.name=fixture -c user.email=fixture@example.org commit -q -m "base")
}
ask() {   # ask <dir> <out file> <prompt> [extra claude flags...]
  local dir="$1" out="$2" prompt="$3"; shift 3
  # Read-only git is allowed, as in a real project: the block needs the base commit.
  (cd "$dir" && "$CLAUDE_BIN" -p "$prompt" --plugin-dir "$REPO" --settings "$WORK/style.json" \
    --permission-mode acceptEdits --tools "Read,Glob,Grep,Edit,Write,Skill,Bash" \
    --allowedTools "Bash(git status:*)" "Bash(git log:*)" "Bash(git rev-parse:*)" \
      "Bash(git diff:*)" "Bash(git merge-base:*)" \
    --output-format text "$@" > "$out" 2> "$out.err")
}
has_closing() { grep -qiE "recommended implementation|implementaci" "$1"; }
# The whole block, in order: the first line, why, scope, a complete command, what to bring back.
has_block() {
  tr '\n' ' ' < "$1" | grep -qE "adr-guard · NEEDED · (audit|plan).*Why:.*Scope:.*Run in a new session:.*/coderachnid:adr-guard[[:space:]]+(plan|audit).*Bring back:"
}
report() {   # report <label> <verdict> <out file>
  [ "$2" = PASS ] || failures=$((failures + 1))
  echo "$1: $2"
  [ "$2" = PASS ] || sed 's/^/    | /' "$3" | tail -14
}

for i in $(seq 1 "$RUNS"); do
  dir="$WORK/risky-$i"; prepare "$dir"
  ask "$dir" "$dir.out" "$RISKY" --no-session-persistence
  if [ ! -s "$dir.out" ]; then v="FAIL (no reply)"
  elif ! has_closing "$dir.out"; then v="FAIL (no five-point closing: the style was not applied)"
  elif ! has_block "$dir.out"; then v="FAIL (no complete recommendation block)"
  elif grep -qE "<id>|<base commit>|<ADR id>" "$dir.out"; then v="FAIL (the command still has placeholders)"
  else v="PASS"; fi
  report "risky #$i" "$v" "$dir.out"
done

for i in $(seq 1 "$RUNS"); do
  dir="$WORK/benign-$i"; prepare "$dir"
  ask "$dir" "$dir.out" "$BENIGN" --no-session-persistence
  if [ ! -s "$dir.out" ]; then v="FAIL (no reply)"
  elif ! has_closing "$dir.out"; then v="FAIL (no five-point closing: the style was not applied)"
  elif grep -q "adr-guard" "$dir.out"; then v="FAIL (mentions adr-guard on a change that doesn't need it)"
  else v="PASS"; fi
  report "benign #$i" "$v" "$dir.out"
done

for i in $(seq 1 "$RUNS"); do
  dir="$WORK/once-$i"; prepare "$dir"
  ask "$dir" "$dir.first" "$RISKY"
  ask "$dir" "$dir.out" "$FOLLOW_UP" --continue
  if [ ! -s "$dir.first" ] || [ ! -s "$dir.out" ]; then v="FAIL (a turn gave no reply)"
  elif ! has_block "$dir.first"; then v="FAIL (first turn: no recommendation block, so 'once' proves nothing)"
  elif ! has_closing "$dir.out"; then v="FAIL (second turn: no five-point closing)"
  elif grep -q "adr-guard · NEEDED" "$dir.out"; then v="FAIL (the block was repeated on a harmless follow-up)"
  else v="PASS"; fi
  report "once #$i" "$v" "$dir.out"
done

[ "$failures" -eq 0 ] && echo "all closing checks pass" || echo "$failures closing check(s) failed"
[ "$failures" -eq 0 ]
