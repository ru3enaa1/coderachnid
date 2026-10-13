import unittest

import db


class CreateNoteTest(unittest.TestCase):
    def setUp(self):
        db.DB_PATH = "test_notes.db"
        db.init()

    def test_create_returns_id(self):
        note = db.create_note("hello", "world")
        self.assertTrue(note["id"])


if __name__ == "__main__":
    unittest.main()
