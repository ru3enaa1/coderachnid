import sqlite3

import pytest

from ledger.accounts import get_balance
from ledger.api import handle_transfer
from ledger.auth import Forbidden
from ledger.db import connect, create_schema, query
from ledger.transfers import InvalidAmount


@pytest.fixture
def conn():
    conn = connect()
    create_schema(conn)
    query(conn, "INSERT INTO accounts VALUES (1, 'ana', 'ana@example.org', 12345)")
    query(conn, "INSERT INTO accounts VALUES (2, 'ana', 'ana@example.org', 0)")
    query(conn, "INSERT INTO accounts VALUES (3, 'leo', 'leo@example.org', 500)")
    conn.commit()  # a failed transfer rolls back only its own transaction
    return conn


def test_transfer_moves_money(conn):
    handle_transfer(conn, "ana", 1, 2, 345)
    assert get_balance(conn, 1) == 12000
    assert get_balance(conn, 2) == 345
    assert query(conn, "SELECT source_id, target_id, amount_cents FROM transfers") == [(1, 2, 345)]


def test_transfer_rejects_foreign_account(conn):
    with pytest.raises(Forbidden):
        handle_transfer(conn, "leo", 1, 3, 100)
    assert get_balance(conn, 1) == 12345


def test_transfer_rejects_foreign_target(conn):
    with pytest.raises(Forbidden):
        handle_transfer(conn, "ana", 1, 3, 100)
    assert get_balance(conn, 1) == 12345
    assert get_balance(conn, 3) == 500


@pytest.mark.parametrize("amount", [1.5, 100.0, True])
def test_transfer_rejects_float(conn, amount):
    with pytest.raises(InvalidAmount):
        handle_transfer(conn, "ana", 1, 2, amount)


@pytest.mark.parametrize("amount", [0, -5])
def test_transfer_rejects_non_positive(conn, amount):
    with pytest.raises(InvalidAmount):
        handle_transfer(conn, "ana", 1, 2, amount)


def test_failed_transfer_changes_nothing(conn, monkeypatch):
    # Fail on the last statement, after both balances were written: only the transaction
    # can undo them. (Failing on the first statement would pass without a transaction.)
    import ledger.transfers as transfers

    def failing_query(conn, sql, params=()):
        if sql.startswith("INSERT INTO transfers"):
            raise sqlite3.IntegrityError("simulated failure after the balance updates")
        return query(conn, sql, params)

    monkeypatch.setattr(transfers, "query", failing_query)
    with pytest.raises(sqlite3.IntegrityError):
        handle_transfer(conn, "ana", 1, 2, 100)
    assert get_balance(conn, 1) == 12345
    assert get_balance(conn, 2) == 0
    assert query(conn, "SELECT COUNT(*) FROM transfers") == [(0,)]
