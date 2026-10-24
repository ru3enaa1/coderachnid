#!/usr/bin/env bash
# Shared helpers for the coderachnid-relay hooks.
#
# Written for plain bash, grep, sed and tail, so the hooks run in Git Bash on Windows,
# on macOS and on Linux without jq, Python or Node. Hook input is one JSON object on
# stdin; the fields read here are flat, so a pattern match is enough.
#
# Every hook must leave the session working whatever happens: callers exit 0 on any
# problem and print nothing.

# read_input: stores the hook's JSON input in $input.
read_input() { input="$(cat 2>/dev/null)"; }

# json_str <key>: a string field, with JSON backslash escapes (\\) undone.
json_str() {
  printf '%s' "$input" | grep -o "\"$1\" *: *\"[^\"]*\"" | head -n 1 \
    | sed "s/^\"$1\" *: *\"//; s/\"\$//; s/\\\\\\\\/\\\\/g"
}

# json_num <key>: an integer field (digits only), empty if absent.
json_num() {
  printf '%s' "$input" | grep -o "\"$1\" *: *[0-9]*" | head -n 1 | grep -o '[0-9]*$'
}

# json_raw <key>: a number or boolean field as written (true, false, 1.25).
json_raw() {
  printf '%s' "$input" | grep -o "\"$1\" *: *[A-Za-z0-9.]*" | head -n 1 | sed "s/^\"$1\" *: *//"
}

# to_unix_path <path>: Windows paths become paths bash can open.
to_unix_path() {
  if [ -n "$1" ] && command -v cygpath > /dev/null 2>&1; then cygpath -u "$1"; else printf '%s' "$1"; fi
}

# project_dir: the project root, from Claude Code's environment or the hook input.
project_dir() {
  local dir="${CLAUDE_PROJECT_DIR:-}"
  [ -n "$dir" ] || dir="$(json_str cwd)"
  [ -n "$dir" ] || dir="$(pwd)"
  to_unix_path "$dir"
}
