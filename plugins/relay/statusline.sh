#!/usr/bin/env bash
# Status line for Claude Code: tokens in the current context and, on Pro and Max plans,
# how much of the five-hour usage limit is spent. Plain bash and grep, no jq.
#
#   ctx 182k/1000k (18%) · 5h 41%
#
# Setup (once): copy this file to ~/.claude/coderachnid-statusline.sh and add to
# ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/coderachnid-statusline.sh" }
input="$(cat 2> /dev/null)"

num() { printf '%s' "$input" | grep -o "\"$1\" *: *[0-9.]*" | head -n 1 | sed "s/^\"$1\" *: *//; s/\..*//"; }

used="$(num total_input_tokens)"
size="$(num context_window_size)"
five="$(printf '%s' "$input" | grep -o '"five_hour" *: *{[^}]*}' | grep -o '"used_percentage" *: *[0-9.]*' \
  | head -n 1 | sed 's/.*: *//; s/\..*//')"

line=""
if [ -n "$used" ] && [ -n "$size" ] && [ "$size" -gt 0 ] 2> /dev/null; then
  line="ctx $(( used / 1000 ))k/$(( size / 1000 ))k ($(( used * 100 / size ))%)"
fi
if [ -n "$five" ]; then
  line="${line:+$line · }5h ${five}%"
fi
printf '%s\n' "${line:-ctx -}"
