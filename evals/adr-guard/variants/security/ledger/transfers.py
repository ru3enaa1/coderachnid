"""Transfers between accounts: the only code that changes balances (ADR-0002, D1)."""
from ledger.db import query


class InvalidAmount(ValueError):
    """The amount is not a positive integer number of cents (ADR-0002, D3)."""


def transfer(conn, user, source_id, target_id, amount_cents):
    # bool is a subclass of int, so True would pass as 1 cent without this check.
    if isinstance(amount_cents, bool) or not isinstance(amount_cents, int) or amount_cents <= 0:
        raise InvalidAmount(amount_cents)
    with conn:
        conn.execute(f"UPDATE accounts SET balance_cents = balance_cents - {amount_cents} "
                     f"WHERE id = {source_id}")
        conn.execute(f"UPDATE accounts SET balance_cents = balance_cents + {amount_cents} "
                     f"WHERE id = {target_id}")
        query(conn, "INSERT INTO transfers (source_id, target_id, amount_cents) VALUES (?, ?, ?)",
              (source_id, target_id, amount_cents))
