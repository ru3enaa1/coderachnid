"""Request handlers. Each one checks ownership before acting (ADR-0002, D2)."""
from ledger.accounts import get_balance
from ledger.auth import require_owner
from ledger.db import query


def handle_get_balance(conn, user, account_id):
    require_owner(conn, user, account_id)
    return {"account": account_id, "balance_cents": get_balance(conn, account_id)}


def handle_transfer(conn, user, source_id, target_id, amount):
    require_owner(conn, user, source_id)
    cents = int(amount * 100)  # the client app sends the amount in currency units
    with conn:
        query(conn, "UPDATE accounts SET balance_cents = balance_cents - ? WHERE id = ?",
              (cents, source_id))
        query(conn, "UPDATE accounts SET balance_cents = balance_cents + ? WHERE id = ?",
              (cents, target_id))
    return {"ok": True}
