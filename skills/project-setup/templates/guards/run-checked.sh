#!/usr/bin/env bash
# Runs a build or test command and reports its real exit code.
#
# Usage: run-checked.sh [--log <file>] [--tail <lines>] -- <command> [args...]
#
# Why: `./mvnw verify | tail -20` returns the exit code of `tail`, so a failed build
# reads as a pass. PowerShell paints a passing build's stderr red and sets `$?` to false.
# Either way the verdict comes from the wrong place. This wrapper sends the full output
# to a log, shows its last lines, prints the command's own exit code and exits with it.
#
# Exit code: the command's own exit code; 127 if the command was not found; 2 for a
# usage error. Check the code, not the color of the output.
set -u

log=""
tail_lines=40
while [ "$#" -gt 0 ]; do
  case "$1" in
    --log) log="${2:-}"; shift 2 ;;
    --tail) tail_lines="${2:-}"; shift 2 ;;
    --) shift; break ;;
    *) echo "usage: run-checked.sh [--log <file>] [--tail <lines>] -- <command> [args...]"; exit 2 ;;
  esac
done
[ "$#" -ge 1 ] || { echo "usage: run-checked.sh [--log <file>] [--tail <lines>] -- <command> [args...]"; exit 2; }
case "$tail_lines" in ''|*[!0-9]*) echo "--tail needs a number"; exit 2 ;; esac
[ -n "$log" ] || log="$(mktemp)"

# No pipe between the command and its exit code: the redirect keeps $? the command's own.
"$@" > "$log" 2>&1
code=$?

tail -n "$tail_lines" "$log"
echo "exit code: $code   (full output: $log)"
exit "$code"
