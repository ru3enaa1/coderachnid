"""Account reads. Public API: other teams' services and the reports call it."""
from ledger.db import query


def get_balance(conn, account_id):
    """Balance in integer cents (ADR-0001)."""
    rows = query(conn, "SELECT balance_cents FROM accounts WHERE id = ?", (account_id,))
    if not rows:
        raise KeyError(account_id)
    return rows[0][0]
