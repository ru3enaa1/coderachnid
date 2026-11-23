import pytest

from ledger.api import handle_get_balance
from ledger.auth import Forbidden
from ledger.db import connect, create_schema, query
from ledger.reports import statement_line


@pytest.fixture
def conn():
    conn = connect()
    create_schema(conn)
    query(conn, "INSERT INTO accounts VALUES (1, 'ana', 'ana@example.org', 12345)")
    query(conn, "INSERT INTO accounts VALUES (2, 'ana', 'ana@example.org', 0)")
    query(conn, "INSERT INTO accounts VALUES (3, 'leo', 'leo@example.org', 500)")
    conn.commit()
    return conn


def test_owner_reads_balance(conn):
    assert handle_get_balance(conn, "ana", 1) == {"account": 1, "balance_cents": 12345}


def test_other_user_cannot_read_balance(conn):
    with pytest.raises(Forbidden):
        handle_get_balance(conn, "leo", 1)


def test_statement_line_formats_cents(conn):
    assert statement_line(conn, 1) == "Account 1: 123.45"
