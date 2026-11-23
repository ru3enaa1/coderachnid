CREATE TABLE accounts (
  id            INTEGER PRIMARY KEY,
  owner         TEXT    NOT NULL,
  email         TEXT    NOT NULL,
  balance_cents INTEGER NOT NULL CHECK (balance_cents >= 0)
) STRICT;

CREATE TABLE transfers (
  id           INTEGER PRIMARY KEY,
  source_id    INTEGER NOT NULL REFERENCES accounts(id),
  target_id    INTEGER NOT NULL REFERENCES accounts(id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0)
) STRICT;
