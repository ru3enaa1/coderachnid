#!/usr/bin/env bash
# SessionStart (resume): warn before a large conversation is reloaded with an expired
# prompt cache. Resuming then re-sends the whole conversation at full price; a handoff
# and /clear continue the same work with a few thousand tokens instead.
# Claude Code provides context_tokens and prompt_cache_likely_expired on resume.
# Always exits 0.
set -u
. "$(dirname "$0")/lib.sh" || exit 0
read_input

tokens="$(json_num context_tokens)"
expired="$(json_raw prompt_cache_likely_expired)"
usd="$(json_raw estimated_cache_write_usd)"
limit="${CODERACHNID_RELAY_RESUME_TOKENS:-100000}"

[ -n "$tokens" ] || exit 0
[ "$expired" = "true" ] || exit 0
[ "$tokens" -ge "$limit" ] 2> /dev/null || exit 0

cost=""
[ -n "$usd" ] && cost=" (about \$$usd to rebuild it at API prices)"
echo "[coderachnid-relay] This resumed conversation re-sends about $tokens tokens and its"
echo "prompt cache has likely expired$cost. Before anything else, tell the user in one line"
echo "and offer to write the handoff (coderachnid:handoff) so they can type /clear and"
echo "continue the same work with a small context."
exit 0
