#!/usr/bin/env bash
# Activation trial (F1): runs every prompt in prompts.tsv in a headless Claude Code
# session with this plugin loaded, and records which coderachnid skills were invoked.
#
# Usage:   bash evals/activation/run.sh <sandbox-project-dir> [skill]
#          The optional skill name runs only that skill's two prompts.
# Needs:   the claude CLI (set CLAUDE_BIN when it is not on PATH) and a sandbox project
#          that is a git repository: it is reset with `git checkout` + `git clean -fdx`
#          before every prompt, so never point it at a real project.
# Safety:  sessions run with edit and shell tools disabled, so nothing is changed.
#          A skill is invoked before any edit, so activation is still observable.
# Cost:    every prompt is one real session on your plan.
# Output:  evals/activation/results/<timestamp>.tsv, one row per prompt.
# Exit:    0 when every prompt behaved as expected, 1 otherwise, 2 on setup errors.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
SANDBOX="${1:-}"
ONLY="${2:-}"
CLAUDE="${CLAUDE_BIN:-claude}"

[ -n "$SANDBOX" ] || { echo "usage: run.sh <sandbox-project-dir> [skill]"; exit 2; }
git -C "$SANDBOX" rev-parse --is-inside-work-tree > /dev/null 2>&1 \
  || { echo "$SANDBOX is not a git repository; refusing to reset it"; exit 2; }
command -v "$CLAUDE" > /dev/null 2>&1 || [ -x "$CLAUDE" ] \
  || { echo "claude CLI not found; set CLAUDE_BIN"; exit 2; }

# The CLI is a Windows binary on Windows: hand it a Windows path.
plugin="$ROOT"
command -v cygpath > /dev/null 2>&1 && plugin="$(cygpath -w "$ROOT")"

# Only names of this plugin's skills count as an activation.
skills="$(find "$ROOT/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | sed 's|/SKILL.md$||; s|.*/||' | sort)"

mkdir -p "$HERE/results"
out="$HERE/results/$(date +%Y-%m-%d-%H%M).tsv"
printf 'skill\texpect\tinvoked\tverdict\tprompt\n' > "$out"
pass=0
fail=0

while IFS=$'\t' read -r skill expect prompt; do
  prompt="${prompt%$'\r'}"
  [ "$skill" = "skill" ] && continue
  [ -n "$ONLY" ] && [ "$skill" != "$ONLY" ] && continue

  git -C "$SANDBOX" checkout -q -- . && git -C "$SANDBOX" clean -qfdx

  log="$(cd "$SANDBOX" && "$CLAUDE" -p "$prompt" \
    --plugin-dir "$plugin" \
    --output-format stream-json --verbose \
    --no-session-persistence \
    --disallowedTools "Edit Write NotebookEdit Bash PowerShell" 2>&1)"

  # Every Skill tool call carries {"skill":"<plugin>:<name>"}; keep only our names.
  invoked="$(printf '%s' "$log" | grep -oE '"skill" *: *"[^"]+"' | sed -E 's/.*"([^"]+)"$/\1/; s/^coderachnid://' \
    | grep -xF -f <(printf '%s\n' "$skills") | sort -u | paste -sd, -)"
  if ! printf '%s' "$log" | grep -q '"type":"result"'; then
    verdict="error"
  elif [ "$expect" = "yes" ] && printf ',%s,' "$invoked" | grep -q ",$skill,"; then
    verdict="pass"
  elif [ "$expect" = "no" ] && ! printf ',%s,' "$invoked" | grep -q ",$skill,"; then
    verdict="pass"
  else
    verdict="fail"
  fi
  [ "$verdict" = "pass" ] && pass=$((pass + 1)) || fail=$((fail + 1))

  printf '%s\t%s\t%s\t%s\t%s\n' "$skill" "$expect" "${invoked:--}" "$verdict" "$prompt" >> "$out"
  printf '%-5s %-17s expect=%-3s invoked=%s\n' "$verdict" "$skill" "$expect" "${invoked:--}"
done < "$HERE/prompts.tsv"

git -C "$SANDBOX" checkout -q -- . && git -C "$SANDBOX" clean -qfdx
echo "$pass passed, $fail failed -> ${out#"$ROOT"/}"
[ "$fail" -eq 0 ]
