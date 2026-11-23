"""Authorization helpers."""
from ledger.db import query


class Forbidden(Exception):
    """The user may not act on this resource."""


def require_owner(conn, user, account_id):
    """Raise Forbidden unless `user` owns `account_id`."""
    rows = query(conn, "SELECT owner FROM accounts WHERE id = ?", (account_id,))
    if not rows or rows[0][0] != user:
        raise Forbidden(f"{user} does not own account {account_id}")
