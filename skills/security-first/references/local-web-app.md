# Hardening a local web app

For desktop-style apps that run a web server on the user's machine and open it in a
browser window. Each control below has bitten a real project when it was missing.

## The server

- **Bind to `127.0.0.1` only**, never `0.0.0.0`. Test it: connecting through the
  machine's LAN IP must fail.
- **Firewalls drop silently.** Connecting to a port that is not listening on the LAN
  interface may give a *timeout* rather than *connection refused*. The test accepts both.
- **Ephemeral port in production**, fixed port only in development, and never one
  that another local project already uses.
- **One-time launch token.** The launcher opens the window with a single-use token that
  becomes a session cookie. A reused token returns 403.
- **Validate the `Host` header** against `127.0.0.1:<port>` / `localhost:<port>`.
  This blocks DNS-rebinding attacks from malicious websites.
- **CSRF on every POST**, even on loopback: any website the user visits can make the
  browser send a request to localhost.
- **Strict CSP** (`default-src 'self'`), no inline script or style. Vendor JS and fonts
  are served locally, with their version, license and SHA-256 recorded.

## The window

- A dedicated browser profile (`--user-data-dir`) runs as its own process, so the app
  knows when the window closes and can shut down.
- Closing the window stops the server. Nothing stays listening in the background.
- If the framework starts headless by default, opening the system browser needs
  headless mode explicitly turned off.

## Proving "zero CSP violations"

A report of zero violations only counts when a **positive control** (a page that
violates the CSP on purpose) shows up in the same log. Otherwise the log may simply not
be capturing anything.

## Tests to have

No cookie → 403 · reused token → 403 · foreign `Host` → 403 · POST without CSRF → 403 ·
LAN IP connection fails · technical log contains no customer name.
