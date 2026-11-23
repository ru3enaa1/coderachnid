"""Monthly statements, built only from the public account API."""
from ledger.accounts import get_balance


def statement_line(conn, account_id):
    cents = get_balance(conn, account_id)
    return f"Account {account_id}: {cents // 100}.{cents % 100:02d}"
