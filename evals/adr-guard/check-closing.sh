#!/usr/bin/env bash
# Checks the closing line of the `coderachnid:closing` output style with real headless
# sessions. `claude plugin eval` can't: its sessions ignore the project's settings and
# start with the default output style (seen in the trace's init line, 2026-11-23).
#
# Two prompts on the fictional ledger fixture, each run RUNS times:
#   risky  : write code that changes an account's email -> the reply names the command;
#   benign : fix a typo in the README                    -> the reply never mentions it.
# Each reply must also carry the five-point closing, or the style was not applied and
# the run proves nothing.
#
# Usage: CLAUDE_BIN="<path to claude>" bash evals/adr-guard/check-closing.sh [RUNS]
# Every run is a real session on your plan (a few cents each). Sessions are not saved.
# Exit code: 0 when every run passes, 1 otherwise, 2 when nothing could run.
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
FIXTURE="$REPO/evals/adr-guard/workspace"
RUNS="${1:-2}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
command -v "$CLAUDE_BIN" > /dev/null 2>&1 || [ -x "$CLAUDE_BIN" ] || {
  echo "claude not found: set CLAUDE_BIN; nothing was checked"; exit 2; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
printf '%s\n' '{ "outputStyle": "coderachnid:closing" }' > "$WORK/style.json"

RISKY="Add handle_change_email(conn, user, account_id, new_email) to ledger/api.py so the account owner can change the account's email. Keep it small."
BENIGN="Fix the typo in README.md: 'recieve' should be 'receive'."

failures=0
run_case() {
  local label="$1" prompt="$2" expect="$3" i
  for i in $(seq 1 "$RUNS"); do
    local dir="$WORK/$label-$i"
    mkdir -p "$dir" && cp -R "$FIXTURE/." "$dir/"
    (cd "$dir" && "$CLAUDE_BIN" -p "$prompt" --plugin-dir "$REPO" --settings "$WORK/style.json" \
      --permission-mode acceptEdits --tools "Read,Glob,Grep,Edit,Write,Skill" \
      --no-session-persistence --output-format text > "$dir.out" 2> "$dir.err")
    local status=$? verdict
    if [ "$status" -ne 0 ] || [ ! -s "$dir.out" ]; then
      verdict="FAIL (session exit $status, no reply)"
    elif ! grep -qiE "recommended implementation|implementaci" "$dir.out"; then
      verdict="FAIL (no five-point closing: the style was not applied)"
    elif [ "$expect" = mention ] && ! grep -qE "/coderachnid:adr-guard[[:space:]]+(plan|audit)" "$dir.out"; then
      verdict="FAIL (closing without the adr-guard command)"
    elif [ "$expect" = silent ] && grep -q "adr-guard" "$dir.out"; then
      verdict="FAIL (mentions adr-guard on a change that doesn't need it)"
    else
      verdict="PASS"
    fi
    [ "$verdict" = PASS ] || failures=$((failures + 1))
    echo "$label #$i: $verdict"
    [ "$verdict" = PASS ] || sed 's/^/    | /' "$dir.out" | tail -12
  done
}

run_case risky "$RISKY" mention
run_case benign "$BENIGN" silent
[ "$failures" -eq 0 ] && echo "all closing checks pass" || echo "$failures closing check(s) failed"
[ "$failures" -eq 0 ]
