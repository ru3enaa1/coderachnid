# SQLite pitfalls

- **`foreign_keys` is OFF by default and is set per connection**, not per database.
  Enable it in the connection factory or pool initializer, and test it: deleting a parent
  that still has children must fail.
- **Without `STRICT`, SQLite stores text in numeric columns** without complaint. Use
  `STRICT` tables.
- **Testing STRICT on the primary key passes vacuously.** An `INTEGER PRIMARY KEY`
  rejects text even without STRICT. Test STRICT on an ordinary column.
- **WAL mode writes to `-wal` and `-shm` files.** A backup of only the main file loses
  recent writes. Copy all three, or use `VACUUM INTO` with the app stopped.
- Set `journal_mode=WAL` and a `busy_timeout` per connection as well.
- **One database = one file** fits documents the user owns (a "project file"). Give it
  its own extension and a version table, and refuse files newer than the app.
- **Migration tools may log the JDBC URL**, which includes the file name, which may
  include a customer's name. Raise that logger to WARN.
- **Viewers filter by extension.** A custom extension (`.myapp`) is hidden in the open
  dialog of tools like DB Browser for SQLite. Pass the path on the command line and open
  it read-only, with the app stopped.
- `schema.sql` written in SQLite dialect will not run in a MySQL tool. Say so in the file
  header.
