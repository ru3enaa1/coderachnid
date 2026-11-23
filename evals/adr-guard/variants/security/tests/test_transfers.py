import sqlite3

import pytest

from ledger.accounts import get_balance
from ledger.api import handle_transfer
from ledger.db import connect, create_schema, query
from ledger.transfers import InvalidAmount


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
    handle_transfer(conn, "ana", 1, 2, 345)
    assert get_balance(conn, 1) == 12000
    assert get_balance(conn, 2) == 345


@pytest.mark.parametrize("amount", [1.5, 100.0, True])
def test_transfer_rejects_float(conn, amount):
    with pytest.raises(InvalidAmount):
        handle_transfer(conn, "ana", 1, 2, amount)


@pytest.mark.parametrize("amount", [0, -5])
def test_transfer_rejects_non_positive(conn, amount):
    with pytest.raises(InvalidAmount):
        handle_transfer(conn, "ana", 1, 2, amount)


def test_failed_transfer_changes_nothing(conn):
    with pytest.raises(sqlite3.IntegrityError):
        handle_transfer(conn, "ana", 2, 1, 1)
    assert get_balance(conn, 1) == 12345
    assert get_balance(conn, 2) == 0
