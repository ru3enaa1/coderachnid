# Baseline · ADR-0002

- **Date:** 2026-11-20 · **Base commit:** `base` (the code before LED-42) · **Branch:** main
- **Uncommitted changes:** none

| Check | Command | Exit code | Result |
|---|---|---|---|
| Tests | `python -m pytest -q` | 0 | 3 passed, 0 failed |
| Lint | `python -m pyflakes ledger tests` | 0 | 0 warnings |

Tests already failing before the change: none.
