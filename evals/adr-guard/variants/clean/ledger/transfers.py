"""Transfers between accounts: the only code that changes balances (ADR-0002, D1)."""
from ledger.auth import require_owner
from ledger.db import query


class InvalidAmount(ValueError):
    """The amount is not a positive integer number of cents (ADR-0002, D3)."""


def transfer(conn, user, source_id, target_id, amount_cents):
    # bool is a subclass of int, so True would pass as 1 cent without this check.
    if isinstance(amount_cents, bool) or not isinstance(amount_cents, int) or amount_cents <= 0:
        raise InvalidAmount(amount_cents)
    # Owners move money between their own accounts (D2): both ends are checked.
    require_owner(conn, user, source_id)
    require_owner(conn, user, target_id)
    # One transaction: any failing statement rolls back the ones before it (D6).
    with conn:
        query(conn, "UPDATE accounts SET balance_cents = balance_cents - ? WHERE id = ?",
              (amount_cents, source_id))
        query(conn, "UPDATE accounts SET balance_cents = balance_cents + ? WHERE id = ?",
              (amount_cents, target_id))
        query(conn, "INSERT INTO transfers (source_id, target_id, amount_cents) VALUES (?, ?, ?)",
              (source_id, target_id, amount_cents))
