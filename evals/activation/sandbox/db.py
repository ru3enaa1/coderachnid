import sqlite3
from datetime import datetime, timezone

DB_PATH = "notes.db"


def connect():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init():
    with connect() as conn:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
            "id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL, created_at TEXT NOT NULL)"
        )


def create_note(title, body):
    created = datetime.now(timezone.utc).isoformat()
    with connect() as conn:
        cur = conn.execute(
            "INSERT INTO notes (title, body, created_at) VALUES (?, ?, ?)", (title, body, created)
        )
        return {"id": cur.lastrowid, "title": title, "body": body, "created_at": created}


def list_notes():
    with connect() as conn:
        return [dict(r) for r in conn.execute("SELECT * FROM notes")]


def search_notes(q):
    with connect() as conn:
        return [dict(r) for r in conn.execute("SELECT * FROM notes WHERE title LIKE '%" + q + "%'")]
