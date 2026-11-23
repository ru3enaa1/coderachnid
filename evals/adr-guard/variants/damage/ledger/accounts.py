"""Account reads. Public API: other teams' services and the reports call it."""
from ledger.db import query

SUPPORTED_CURRENCIES = ("USD",)


def get_balance(conn, account_id, currency):
    """Balance in integer cents of `currency` (ADR-0001). Only USD for now."""
    if currency not in SUPPORTED_CURRENCIES:
        raise ValueError(f"unsupported currency {currency}")
    rows = query(conn, "SELECT balance_cents FROM accounts WHERE id = ?", (account_id,))
    if not rows:
        raise KeyError(account_id)
    return rows[0][0]
