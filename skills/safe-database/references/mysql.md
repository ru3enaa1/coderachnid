# MySQL (and ORM) pitfalls

- **REPEATABLE READ freezes the snapshot at the first read** of the transaction, even if
  you later wait on a lock. When generating sequential numbers, read the max with
  `SELECT ... FOR UPDATE` (a locking read always sees the latest committed row).
  A concurrency test with two simultaneous saves catches the duplicate.
- **A violated `CHECK` (error 3819) does not arrive as a data-integrity exception**
  (those are for UNIQUE and FK). It arrives as a generic SQL exception, so catch the
  broader data-access exception or validate in the service first.
- **No `ON DELETE CASCADE` / `SET NULL` on a column that feeds a STORED generated
  column.** Delete the dependents first, in the same transaction (for example through a
  domain event).
- **Safe-update mode** in GUI clients rejects `UPDATE` without a key in `WHERE`
  (`WHERE id > 0`).
- **With schema validation at startup, one unapplied migration fails every integration
  test**, not only the ones for its module (`missing column ...`): the ORM checks the
  whole schema when the context starts. Apply migrations before running the suite.
- **The ORM validates column types, not only names.** A `SMALLINT` mapped as a 32-bit
  integer fails at startup. Declare the JDBC type explicitly.
- **Flush order: the ORM runs INSERTs before UPDATEs.** "Close the open one, open a new
  one" under a UNIQUE constraint needs an explicit UPDATE statement first.
- **Clearing the persistence context automatically after a bulk update** detaches
  entities loaded earlier in a long transaction, and their later changes are lost
  silently. Flush automatically, but don't clear.
- **Container env precedence:** Docker Compose prefers OS environment variables over
  `.env`, so a test run may hit real credentials. Unset them for the command.
- **The app user is DML-only.** Migrations and schema changes use a separate user.
