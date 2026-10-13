---
name: safe-database
description: Use before any migration, schema change, data fix, seed, test run or deletion against a database. Enforces the backup, migrate, test, verify sequence, testing only against copies or disposable databases, forward-only migrations and cleanup by id, so original data is never damaged.
---

# Safe database work

The original database is never the test bench. Every structural change follows the same
four steps, in order, with no skipping.

## The ritual: backup → migrate → test → verify

1. **Back up.** Take a complete, restorable copy and put it in
   `database/backups/YYYY-MM-DD-HHMM-reason/`. Confirm the copy opens before continuing.
2. **Migrate** with the versioned migration tool (Flyway, Liquibase, Alembic, Prisma
   migrate…), never by hand-typed DDL.
3. **Test** against a disposable database or a copy: the full suite, plus the
   migration test from each released version.
4. **Verify**: compare row counts, constraints and a sample of real records before and
   after, and confirm the app starts against the migrated schema.

## Backups that actually restore

- **Copy every file the engine uses.** SQLite in WAL mode writes to `-wal` and `-shm`
  next to the main file, so copying only the main file loses the latest writes. Copy all
  three, or run `VACUUM INTO` with the app stopped.
- Server databases: use `pg_dump` or `mysqldump` (with `--single-transaction`), or the
  provider's snapshot. Then **restore it somewhere once**. A backup never restored is a
  hope.
- Backups never go into version control. They may contain real data.

## Where tests run

- **Each integration test gets its own temporary database** (a temp file, an in-memory
  instance or a throwaway container). Nothing is shared and nothing is left behind.
- **Demo or screenshot data goes in a separate test database**, never the real one. It
  carries a visible marker (`DEMO ·`), obeys the app's own rules, and is removed when done.
- **Never test against production or a customer's data.**
- **Clean up by id, don't restore.** Delete exactly the rows the test created, by their
  ids. Restoring a backup also discards legitimate writes made in the meantime.

## Migrations

- **Forward-only and non-destructive:** no `DROP` of data-bearing objects. Rename via
  add-copy-switch, and keep removals for a later release.
- **Applied automatically on open/start**, so a pending migration cannot be forgotten.
  A pending migration can break *every* integration test, not just its module's: schema
  validation at startup checks the whole schema.
- **Keep a sample database from each released version** and test that each one migrates
  and still produces the same results.
- **A database newer than the app is refused** with a clear message, never opened.
- Bulk `UPDATE`s in a migration use a key in the `WHERE` clause. Some clients refuse
  updates without one (safe mode).

## Constraints live in the database too

- **The rule is enforced in both the service and the schema** (`CHECK`, `NOT NULL`,
  `UNIQUE`, foreign keys). Example: "a discard requires a reason" is checked by the
  service *and* by a `CHECK`.
- Use strict typing where the engine offers it (SQLite `STRICT` tables).
- Store money as integers in minor units.
- The application connects with a **least-privilege user** (DML only). Migrations run
  with a separate, more privileged one.

## Visibility

- Keep a readable `schema.sql` (the current shape) next to the migrations, plus invented
  example data and a git-ignored `dev/` folder.
- Inspect databases **read-only, with the app stopped**.

## References

- `references/sqlite.md`: per-connection pragmas, STRICT, WAL, viewers.
- `references/mysql.md`: snapshots, locking, CHECK errors, generated columns, ORM flush order.
