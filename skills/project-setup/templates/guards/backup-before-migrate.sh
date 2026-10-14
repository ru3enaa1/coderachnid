#!/usr/bin/env bash
# Takes a verified backup of a database, so a migration only runs after one exists.
#
# Usage:
#   backup-before-migrate.sh sqlite <database-file> <backup-root> [reason]
#   backup-before-migrate.sh mysql  <database-name> <backup-root> [reason] [-- mysqldump options]
#
#   backup-before-migrate.sh sqlite data/app.db database/backups add-tags && ./migrate
#
# The backup goes to <backup-root>/YYYY-MM-DD-HHMM-<reason>/ and is verified before this
# script reports success:
#   sqlite  SQLite's online backup API copies the database including the -wal file
#           (copying only the main file loses the latest writes). The copy must pass
#           `PRAGMA integrity_check` and hold the same row count in every table.
#   mysql   mysqldump --single-transaction --routines --triggers --events. The dump must
#           exit 0, be non-empty and end with mysqldump's "Dump completed" line (a dump
#           cut short by a lost connection is not a backup). Credentials come from an
#           option file or --login-path, never a password on the command line.
#
# Still restore a backup once somewhere: a backup never restored is a hope.
# Keep <backup-root> out of version control; backups may contain real data.
#
# Exit code: 0 when the backup was taken and verified, 1 when it failed or did not
# verify, 2 for usage or setup errors. A migration must never run on anything but 0.
set -u

usage() {
  echo "usage: backup-before-migrate.sh sqlite <database-file> <backup-root> [reason]"
  echo "       backup-before-migrate.sh mysql  <database-name> <backup-root> [reason] [-- mysqldump options]"
  exit 2
}

engine="${1:-}"
source_db="${2:-}"
root="${3:-}"
[ -n "$engine" ] && [ -n "$source_db" ] && [ -n "$root" ] || usage
shift 3
reason="manual"
if [ "$#" -gt 0 ] && [ "$1" != "--" ]; then reason="$1"; shift; fi
[ "${1:-}" = "--" ] && shift
reason="$(printf '%s' "$reason" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-')"

dest="$root/$(date +%Y-%m-%d-%H%M)-$reason"
if [ -e "$dest" ]; then
  echo "$dest already exists; use another reason or wait a minute"
  exit 2
fi

# Windows Python can't read Git Bash paths such as /tmp; hand it native paths.
native() { if command -v cygpath > /dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }

case "$engine" in
  sqlite)
    [ -f "$source_db" ] || { echo "no database file at $source_db"; exit 2; }
    py=""
    for candidate in python3 python; do
      if "$candidate" -c "import sqlite3" > /dev/null 2>&1; then py="$candidate"; break; fi
    done
    [ -n "$py" ] || { echo "python with sqlite3 is needed for SQLite backups"; exit 2; }
    mkdir -p "$dest"
    target="$dest/$(basename "$source_db")"
    "$py" - "$(native "$source_db")" "$(native "$target")" <<'PY'
import pathlib
import sqlite3
import sys

src_path, dst_path = sys.argv[1], sys.argv[2]
try:
    # Read-only URI built by pathlib, so drive letters and spaces are encoded correctly.
    src = sqlite3.connect(pathlib.Path(src_path).resolve().as_uri() + "?mode=ro", uri=True)
    dst = sqlite3.connect(dst_path)
    src.backup(dst)
    check = dst.execute("PRAGMA integrity_check").fetchone()[0]
    if check != "ok":
        print("backup failed integrity_check: " + check)
        sys.exit(1)
    tables = [r[0] for r in src.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")]
    for table in tables:
        quoted = '"' + table.replace('"', '""') + '"'
        before = src.execute("SELECT COUNT(*) FROM " + quoted).fetchone()[0]
        after = dst.execute("SELECT COUNT(*) FROM " + quoted).fetchone()[0]
        if before != after:
            print("row count differs in " + table + ": " + str(before) + " vs " + str(after))
            sys.exit(1)
    print("verified: integrity ok, " + str(len(tables)) + " table(s) with matching row counts")
except sqlite3.DatabaseError as error:
    print("not a usable SQLite database: " + str(error))
    sys.exit(1)
PY
    status=$?
    if [ "$status" -ne 0 ]; then
      echo "backup NOT verified; do not migrate"
      exit 1
    fi
    echo "backup: $target"
    ;;

  mysql)
    command -v mysqldump > /dev/null 2>&1 || { echo "mysqldump not found"; exit 2; }
    # A password on the command line is visible to every user in the process list.
    for arg in "$@"; do
      case "$arg" in
        --password=*|-p?*) echo "refusing a password on the command line; use an option file or --login-path"; exit 2 ;;
      esac
    done
    mkdir -p "$dest"
    target="$dest/$source_db.sql"
    mysqldump --single-transaction --routines --triggers --events "$@" "$source_db" > "$target"
    status=$?
    if [ "$status" -ne 0 ]; then
      echo "mysqldump exited with $status; backup NOT taken; do not migrate"
      exit 1
    fi
    if [ ! -s "$target" ] || ! tail -n 3 "$target" | grep -q -- "-- Dump completed"; then
      echo "dump is empty or incomplete (no 'Dump completed' line); do not migrate"
      exit 1
    fi
    echo "verified: dump complete"
    echo "backup: $target"
    ;;

  *) usage ;;
esac
