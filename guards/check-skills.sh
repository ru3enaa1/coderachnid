#!/usr/bin/env bash
# Checks the shape of every skill so a broken one never ships:
#   - SKILL.md exists and starts with YAML frontmatter
#   - `name` equals the folder name (Claude Code resolves skills by it)
#   - `description` is present and long enough to trigger reliably
#   - the file stays short (detail belongs in references/)
#   - every `references/x.md` or `templates/x` path mentioned in the skill exists
# Exit code: 0 when all skills pass, 1 otherwise.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAX_LINES=150          # keeps skills cheap to load; see CONTRIBUTING.md
MIN_DESCRIPTION=80     # shorter descriptions rarely say *when* to use the skill
failures=0

fail() { echo "FAIL  $1: $2"; failures=$((failures + 1)); }

for dir in "$ROOT"/skills/*/; do
  skill="$(basename "$dir")"
  before=$failures
  file="$dir/SKILL.md"

  if [ ! -f "$file" ]; then fail "$skill" "missing SKILL.md"; continue; fi
  if [ "$(head -n 1 "$file")" != "---" ]; then fail "$skill" "no frontmatter"; continue; fi

  name="$(sed -n 's/^name: *//p' "$file" | head -n 1)"
  description="$(sed -n 's/^description: *//p' "$file" | head -n 1)"
  lines="$(wc -l < "$file")"

  [ "$name" = "$skill" ] || fail "$skill" "name '$name' does not match folder"
  [ "${#description}" -ge "$MIN_DESCRIPTION" ] || fail "$skill" "description shorter than $MIN_DESCRIPTION chars"
  [ "$lines" -le "$MAX_LINES" ] || fail "$skill" "$lines lines (max $MAX_LINES)"

  # Paths the skill tells the agent to read must exist, or the agent will guess.
  for ref in $(grep -oE '`(references|templates)/[A-Za-z0-9._-]+`' "$file" | tr -d '`' | sort -u); do
    [ -e "$dir/$ref" ] || fail "$skill" "mentions missing $ref"
  done

  # Report "ok" only when this skill added no failure of its own.
  [ "$failures" -eq "$before" ] && echo "ok    $skill ($lines lines)"
done

if [ "$failures" -gt 0 ]; then
  echo "$failures problem(s) found"
  exit 1
fi
echo "all skills pass"
