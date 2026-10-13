"""A tiny notes API. Standard library only."""
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

import db

PORT = 8000


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        url = urlparse(self.path)
        if url.path == "/notes":
            self._send(200, db.list_notes())
        elif url.path == "/notes/search":
            q = parse_qs(url.query).get("q", [""])[0]
            self._send(200, db.search_notes(q))
        else:
            self._send(404, {"error": "not found"})

    def do_POST(self):
        if self.path != "/notes":
            self._send(404, {"error": "not found"})
            return
        length = int(self.headers.get("Content-Length", 0))
        data = json.loads(self.rfile.read(length) or b"{}")
        note = db.create_note(data.get("title", ""), data.get("body", ""))
        self._send(201, note)


def main():
    db.init()
    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
