#!/usr/bin/env bash
# Positive controls for every guard in this repository.
#
# A guard that has never failed proves nothing: "clean" from a check that captured
# nothing looks exactly like "clean" from a check that works. So each rule of each guard
# gets a known-bad fixture that must fail with the documented exit code, and a clean
# fixture that must pass. Fixtures live in a temporary directory and are deleted at the
# end; the real repository is never modified.
#
# Usage: bash guards/tests/test-guards.sh
# Exit code: 0 when every expectation holds, 1 otherwise.
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEMPLATES="$ROOT/skills/project-setup/templates/guards"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass=0
fail=0

# expect <exit-code> <label> <command...>: runs the command and compares its exit code.
expect() {
  local want="$1" label="$2"
  shift 2
  "$@" > "$WORK/last.log" 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
    printf 'ok    %-58s exit %s\n' "$label" "$got"
  else
    fail=$((fail + 1))
    printf 'FAIL  %-58s exit %s, expected %s\n' "$label" "$got" "$want"
    sed 's/^/      | /' "$WORK/last.log" | head -n 8
  fi
}

# ---- check-skills.sh -------------------------------------------------------------

# A copy of what check-skills.sh reads: the guard itself, skills/, README, banners.
skills_fixture() {
  local d="$WORK/skills-$1"
  mkdir -p "$d/guards" "$d/assets"
  cp "$ROOT/guards/check-skills.sh" "$d/guards/"
  cp -R "$ROOT/skills" "$d/"
  cp "$ROOT/README.md" "$d/"
  cp "$ROOT"/assets/banner-*.svg "$d/assets/"
  echo "$d"
}
run_skills() { bash "$1/guards/check-skills.sh"; }

echo "check-skills.sh"
d="$(skills_fixture clean)"
expect 0 "clean copy passes" run_skills "$d"

d="$(skills_fixture missing)"; mkdir "$d/skills/zz-empty"
expect 1 "skill folder without SKILL.md" run_skills "$d"

d="$(skills_fixture frontmatter)"; sed -i '1d' "$d/skills/phased-plan/SKILL.md"
expect 1 "SKILL.md without frontmatter" run_skills "$d"

d="$(skills_fixture name)"; sed -i 's/^name: phased-plan$/name: phased-planner/' "$d/skills/phased-plan/SKILL.md"
expect 1 "name differs from folder" run_skills "$d"

d="$(skills_fixture description)"; sed -i 's/^description: .*/description: Too short./' "$d/skills/phased-plan/SKILL.md"
expect 1 "description under 80 characters" run_skills "$d"

d="$(skills_fixture length)"; yes "filler line" | head -n 200 >> "$d/skills/phased-plan/SKILL.md"
expect 1 "SKILL.md over 150 lines" run_skills "$d"

d="$(skills_fixture reference)"; echo 'Read `references/missing.md` first.' >> "$d/skills/phased-plan/SKILL.md"
expect 1 "mentions a references/ file that does not exist" run_skills "$d"

d="$(skills_fixture template)"; echo 'Copy `templates/missing.sh`.' >> "$d/skills/project-setup/SKILL.md"
expect 1 "mentions a templates/ file that does not exist" run_skills "$d"

d="$(skills_fixture badge)"; sed -i 's/badge\/skills-[0-9]*-/badge\/skills-999-/' "$d/README.md"
expect 1 "README skills badge drifts from the folders" run_skills "$d"

d="$(skills_fixture banner)"; sed -i 's/>[0-9]* skills /\>999 skills /' "$d/assets/banner-dark.svg"
expect 1 "banner skill count drifts from the folders" run_skills "$d"

# ---- check-private-terms.sh -----------------------------------------------------

# A throwaway git repository with fake private terms (never real ones).
terms_fixture() {
  local d="$WORK/terms-$1"
  mkdir -p "$d/guards"
  cp "$ROOT/guards/check-private-terms.sh" "$d/guards/"
  git -C "$d" init -q
  git -C "$d" config core.autocrlf false   # keep fixture commits quiet on Windows
  printf '.private-terms\n' > "$d/.gitignore"
  printf '# fake terms used only by this test\nacme corp\nproject-bluebird\n' > "$d/.private-terms"
  echo "a harmless note" > "$d/notes.txt"
  echo "$d"
}
run_terms() { bash "$1/guards/check-private-terms.sh"; }

echo
echo "check-private-terms.sh"
d="$(terms_fixture clean)"
expect 0 "clean repository passes" run_terms "$d"

d="$(terms_fixture case)"; echo "Built for ACME Corp" > "$d/notes.txt"
expect 1 "term in a different case" run_terms "$d"

# The bug this guard once had: GNU grep 3.0 aborted on -i with several patterns and the
# abort read as "no match". The second term, in upper case, must still be caught.
d="$(terms_fixture second)"; echo "see PROJECT-BLUEBIRD" > "$d/notes.txt"
expect 1 "second term in upper case (grep -i regression)" run_terms "$d"

d="$(terms_fixture ignored)"; printf '.private-terms\nsecret.txt\n' > "$d/.gitignore"; echo "acme corp" > "$d/secret.txt"
expect 0 "term only in a git-ignored file" run_terms "$d"

d="$(terms_fixture unignored)"; rm "$d/.gitignore"
expect 1 "terms file itself not git-ignored" run_terms "$d"

d="$(terms_fixture crlf)"; printf 'acme corp\r\n' > "$d/.private-terms"; echo "acme corp" > "$d/notes.txt"
expect 1 "terms file with CRLF endings still matches" run_terms "$d"

d="$(terms_fixture nogit)"; rm -rf "$d/.git"; echo "acme corp" > "$d/notes.txt"
expect 1 "outside a git repository (find fallback)" run_terms "$d"

# --history: a term committed once and removed later is clean on disk but still public.
d="$(terms_fixture history)"
echo "draft for Acme Corp" > "$d/notes.txt"
git -C "$d" add notes.txt .gitignore
git -C "$d" -c user.name=t -c user.email=t@example.invalid commit -qm "draft"
echo "a harmless note" > "$d/notes.txt"
git -C "$d" -c user.name=t -c user.email=t@example.invalid commit -qam "clean up"
expect 0 "term removed from the files: working tree is clean" run_terms "$d"
expect 1 "--history finds the term in an old commit" bash "$d/guards/check-private-terms.sh" --history

d="$(terms_fixture historyclean)"
git -C "$d" add notes.txt .gitignore
git -C "$d" -c user.name=t -c user.email=t@example.invalid commit -qm "clean"
expect 0 "--history on a clean history passes" bash "$d/guards/check-private-terms.sh" --history
expect 2 "unknown option is a usage error" bash "$d/guards/check-private-terms.sh" --everything

d="$(terms_fixture missing)"; rm "$d/.private-terms"
expect 2 "no terms file: nothing was checked" run_terms "$d"

d="$(terms_fixture empty)"; printf '# only a comment\n\n' > "$d/.private-terms"
expect 2 "terms file without terms: nothing was checked" run_terms "$d"

# ---- templates/guards/check-forbidden-phrases.sh ---------------------------------

echo
echo "check-forbidden-phrases.sh (project template)"
p="$WORK/phrases"; mkdir -p "$p/site"
printf '# promises we cannot prove\nguaranteed\nrisk-free\n' > "$p/list.txt"
echo "Results you can check yourself." > "$p/site/index.html"
expect 0 "clean text passes" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/list.txt" "$p/site"

echo "Returns GUARANTEED." > "$p/site/offer.html"
expect 1 "phrase in a different case" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/list.txt" "$p/site"
rm "$p/site/offer.html"

echo "A Risk-Free trial." > "$p/site/trial.md"
expect 1 "second phrase (several patterns at once)" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/list.txt" "$p/site"
rm "$p/site/trial.md"

expect 2 "missing phrases file" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/none.txt" "$p/site"
printf '# nothing yet\n' > "$p/empty.txt"
expect 2 "phrases file without phrases" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/empty.txt" "$p/site"
expect 2 "missing path" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/list.txt" "$p/nowhere"
mkdir "$p/blank"
expect 2 "path with no text files" bash "$TEMPLATES/check-forbidden-phrases.sh" "$p/list.txt" "$p/blank"

# ---- templates/guards/check-line-endings.sh --------------------------------------

lf_fixture() {
  local d="$WORK/lf-$1"
  mkdir -p "$d/golden"
  git -C "$d" init -q
  printf '*.txt text eol=lf\n' > "$d/.gitattributes"
  printf 'line one\nline two\n' > "$d/golden/expected.txt"
  echo "$d"
}
run_lf() { (cd "$1" && bash "$TEMPLATES/check-line-endings.sh" "${@:2}"); }

echo
echo "check-line-endings.sh (project template)"
d="$(lf_fixture clean)"
expect 0 "pinned to LF and LF on disk" run_lf "$d" '*.txt'

d="$(lf_fixture unpinned)"; rm "$d/.gitattributes"
expect 1 "not pinned in .gitattributes" run_lf "$d" '*.txt'

d="$(lf_fixture crlf)"; printf 'line one\r\nline two\r\n' > "$d/golden/expected.txt"
expect 1 "CRLF on disk" run_lf "$d" '*.txt'

d="$(lf_fixture nomatch)"
expect 2 "no file matches: nothing was checked" run_lf "$d" '*.svg'

d="$WORK/lf-nogit"; mkdir -p "$d"; printf 'x\n' > "$d/a.txt"
expect 2 "not a git repository" run_lf "$d" '*.txt'

# ---- templates/guards/run-checked.sh ---------------------------------------------

RC="$TEMPLATES/run-checked.sh"
echo
echo "run-checked.sh (project template)"
expect 0 "passing command exits 0" bash "$RC" -- bash -c 'echo built; exit 0'
expect 3 "failing command keeps its own exit code" bash "$RC" -- bash -c 'echo broken; exit 3'
expect 0 "stderr reaches the shown output" bash -c "bash '$RC' -- bash -c 'echo trace-on-stderr >&2; exit 4' | grep -q trace-on-stderr"
expect 127 "missing command reports 127" bash "$RC" -- no-such-command-coderachnid
expect 2 "no command is a usage error" bash "$RC" --
expect 2 "non-numeric --tail is a usage error" bash "$RC" --tail many -- true

# ---- templates/guards/backup-before-migrate.sh -----------------------------------

BK="$TEMPLATES/backup-before-migrate.sh"
native() { if command -v cygpath > /dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }
PY=""
for candidate in python3 python; do
  if "$candidate" -c "import sqlite3" > /dev/null 2>&1; then PY="$candidate"; break; fi
done

echo
echo "backup-before-migrate.sh (project template)"
b="$WORK/backup"; mkdir -p "$b/data"
if [ -n "$PY" ]; then
  # A WAL-mode database with rows, created the way an app would.
  "$PY" -c "import sqlite3, sys; c = sqlite3.connect(sys.argv[1]); c.execute('PRAGMA journal_mode=WAL'); c.execute('CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT)'); c.executemany('INSERT INTO notes (title) VALUES (?)', [('a',), ('b',), ('c',)]); c.commit()" "$(native "$b/data/notes.db")"
  expect 0 "sqlite: backup taken and verified" bash "$BK" sqlite "$b/data/notes.db" "$b/root" add-tags
  expect 0 "sqlite: backup file written under a dated folder" bash -c "find '$b/root' -path '*-add-tags/notes.db' | grep -q ."
  echo "not a database" > "$b/data/fake.db"
  expect 1 "sqlite: a file that is not a database fails" bash "$BK" sqlite "$b/data/fake.db" "$b/root" fake
else
  echo "skip  sqlite cases: no python with sqlite3"
fi
expect 2 "sqlite: missing database file" bash "$BK" sqlite "$b/data/none.db" "$b/root" missing
expect 2 "unknown engine is a usage error" bash "$BK" oracle shop "$b/root"

# A stand-in for mysqldump: no server is needed to test what the guard does with a
# good dump, a failed one and one cut short.
mkdir -p "$b/bin"
cat > "$b/bin/mysqldump" <<'STUB'
#!/usr/bin/env bash
case "${STUB_MODE:-ok}" in
  ok) echo "CREATE TABLE notes (id INT);"; echo "-- Dump completed on 2026-10-14 12:00:00" ;;
  fail) echo "mysqldump: Got error: 2003: Can't connect" >&2; exit 2 ;;
  truncated) echo "CREATE TABLE notes (id INT);"; echo "INSERT INTO notes VALUES (1" ;;
esac
STUB
chmod +x "$b/bin/mysqldump"
expect 0 "mysql: complete dump is verified" env STUB_MODE=ok PATH="$b/bin:$PATH" bash "$BK" mysql shop "$b/root" ok
expect 1 "mysql: mysqldump error fails" env STUB_MODE=fail PATH="$b/bin:$PATH" bash "$BK" mysql shop "$b/root" fail
expect 1 "mysql: dump cut short fails" env STUB_MODE=truncated PATH="$b/bin:$PATH" bash "$BK" mysql shop "$b/root" cut
expect 2 "mysql: --password= on the command line is refused" env PATH="$b/bin:$PATH" bash "$BK" mysql shop "$b/root" pw1 -- --password=secret
expect 2 "mysql: -p<password> on the command line is refused" env PATH="$b/bin:$PATH" bash "$BK" mysql shop "$b/root" pw2 -- -psecret

# ---- plugins/relay (coderachnid-relay hooks and status line) --------------------

RELAY="$ROOT/plugins/relay"
rl="$WORK/relay"
proj="$rl/proj"
mkdir -p "$proj/.coderachnid"
# relay <script> <json>: runs a hook script on JSON input, outside any Claude session;
# its output goes to $rl/out.
relay() { printf '%s' "$2" | env -u CLAUDE_PROJECT_DIR bash "$RELAY/scripts/$1" > "$rl/out" 2>&1; }
has() { grep -q -- "$1" "$rl/out"; }
silent() { [ ! -s "$rl/out" ]; }
win_escaped() { cygpath -w "$1" | sed 's/\\/\\\\/g'; }   # how JSON carries a Windows path

echo
echo "coderachnid-relay hooks"
for script in $(grep -o 'scripts/[a-z-]*\.sh' "$RELAY/hooks/hooks.json" | sort -u); do
  expect 0 "hooks.json points to an existing $script" test -f "$RELAY/$script"
done

j="{\"source\":\"startup\",\"cwd\":\"$proj\"}"
expect 0 "session-start: exits 0 without a handoff" relay session-start.sh "$j"
expect 0 "session-start: prints nothing without a handoff" silent
printf '# Handoff\ncodeword: amber-thread\n' > "$proj/.coderachnid/HANDOFF.md"
echo 150000 > "$proj/.coderachnid/.relay-warned"
relay session-start.sh "$j"
expect 0 "session-start: injects the handoff" has "amber-thread"
expect 0 "session-start: clears the size warning marker" test ! -e "$proj/.coderachnid/.relay-warned"
if command -v cygpath > /dev/null 2>&1; then
  relay session-start.sh "{\"source\":\"clear\",\"cwd\":\"$(win_escaped "$proj")\"}"
  expect 0 "session-start: reads an escaped Windows path" has "amber-thread"
fi

relay resume-check.sh '{"source":"resume","context_tokens":250000,"prompt_cache_likely_expired":true,"estimated_cache_write_usd":1.87}'
expect 0 "resume-check: warns on a large resume with an expired cache" has "re-sends about 250000"
relay resume-check.sh '{"source":"resume","context_tokens":250000,"prompt_cache_likely_expired":false}'
expect 0 "resume-check: quiet while the cache is warm" silent
relay resume-check.sh '{"source":"resume","context_tokens":20000,"prompt_cache_likely_expired":true}'
expect 0 "resume-check: quiet on a small conversation" silent
relay resume-check.sh '{"source":"resume"}'
expect 0 "resume-check: quiet when the fields are absent" silent

t="$rl/transcript.jsonl"
usage_line() { printf '{"type":"assistant","message":{"usage":{"input_tokens":2,"cache_creation_input_tokens":1000,"cache_read_input_tokens":%s,"output_tokens":10}}}\n' "$1"; }
{ usage_line 5000; usage_line 150000; } > "$t"
j="{\"transcript_path\":\"$t\",\"cwd\":\"$proj\"}"
CODERACHNID_RELAY_TOKENS=200000 relay context-check.sh "$j"
expect 0 "context-check: quiet below the threshold" silent
relay context-check.sh "$j"
expect 0 "context-check: warns past the threshold (sums the last usage)" has "about 151002 tokens"
expect 0 "context-check: remembers the warned size" grep -q '^151002$' "$proj/.coderachnid/.relay-warned"
relay context-check.sh "$j"
expect 0 "context-check: quiet again within the same size band" silent
usage_line 220000 >> "$t"
relay context-check.sh "$j"
expect 0 "context-check: warns again one step later" has "about 221002 tokens"
relay context-check.sh "{\"transcript_path\":\"$rl/none.jsonl\",\"cwd\":\"$proj\"}"
expect 0 "context-check: quiet when the transcript is missing" silent
if command -v cygpath > /dev/null 2>&1; then
  rm -f "$proj/.coderachnid/.relay-warned"
  relay context-check.sh "{\"transcript_path\":\"$(win_escaped "$t")\",\"cwd\":\"$(win_escaped "$proj")\"}"
  expect 0 "context-check: reads escaped Windows paths" has "about 221002 tokens"
fi

# In the JSON below, \n is a newline and \" a quote, as Claude Code sends them.
j="{\"trigger\":\"auto\",\"cwd\":\"$proj\",\"compact_summary\":\"Line one\\nLine \\\"two\\\"\"}"
relay save-compact.sh "$j"
saved="$(ls -1t "$proj/.coderachnid/compact"/compact-*.md 2> /dev/null | head -n 1)"
expect 0 "save-compact: writes the summary to a file" test -n "$saved"
expect 0 "save-compact: undoes newline and quote escapes" grep -q '^Line "two"$' "${saved:-/nonexistent}"
for i in 1 2 3 4 5 6; do touch -d "2020-01-0$i" "$proj/.coderachnid/compact/compact-2020010$i-000000.md"; done
relay save-compact.sh "$j"
expect 0 "save-compact: keeps only the five most recent" test "$(ls -1 "$proj/.coderachnid/compact"/compact-*.md | wc -l)" -le 5

sl() { printf '%s' "$1" | bash "$RELAY/statusline.sh"; }
expect 0 "statusline: context and five-hour limit" test "$(sl '{"context_window":{"total_input_tokens":182000,"context_window_size":1000000},"rate_limits":{"five_hour":{"used_percentage":41.2}}}')" = "ctx 182k/1000k (18%) · 5h 41%"
expect 0 "statusline: placeholder before the first response" test "$(sl '{}')" = "ctx -"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
