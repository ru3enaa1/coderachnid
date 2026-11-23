"""Database access. Every statement goes through query() with parameters (ADR-0002, D4)."""
import sqlite3
from pathlib import Path

SCHEMA = Path(__file__).with_name("schema.sql")


def connect(path=":memory:"):
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def create_schema(conn):
    conn.executescript(SCHEMA.read_text(encoding="utf-8"))


def query(conn, sql, params=()):
    """Run one parameterized statement and return all rows."""
    return conn.execute(sql, params).fetchall()
