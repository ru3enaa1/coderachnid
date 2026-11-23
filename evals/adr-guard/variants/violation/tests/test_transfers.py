import pytest

from ledger.accounts import get_balance
from ledger.api import handle_transfer
from ledger.auth import Forbidden
from ledger.db import connect, create_schema, query


@pytest.fixture
def conn():
    conn = connect()
    create_schema(conn)
    query(conn, "INSERT INTO accounts VALUES (1, 'ana', 'ana@example.org', 12345)")
    query(conn, "INSERT INTO accounts VALUES (2, 'ana', 'ana@example.org', 0)")
    query(conn, "INSERT INTO accounts VALUES (3, 'leo', 'leo@example.org', 500)")
    conn.commit()
    return conn


def test_transfer_moves_money(conn):
    handle_transfer(conn, "ana", 1, 2, 2.5)
    assert get_balance(conn, 1) == 12095
    assert get_balance(conn, 2) == 250


def test_transfer_rejects_foreign_account(conn):
    with pytest.raises(Forbidden):
        handle_transfer(conn, "leo", 1, 3, 1)
