"""Request handlers. Each one checks ownership before acting (ADR-0002, D2)."""
from ledger.accounts import get_balance
from ledger.auth import require_owner
from ledger.transfers import transfer


def handle_get_balance(conn, user, account_id):
    require_owner(conn, user, account_id)
    return {"account": account_id, "balance_cents": get_balance(conn, account_id)}


def handle_transfer(conn, user, source_id, target_id, amount_cents):
    transfer(conn, user, source_id, target_id, amount_cents)
    return {"ok": True}
