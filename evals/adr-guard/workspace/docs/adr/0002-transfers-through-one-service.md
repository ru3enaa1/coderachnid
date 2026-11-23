# ADR-0002 · Transfers go through one service

- **Date:** 2026-11-20 · **Status:** accepted · **Task:** LED-42, "let owners move money
  between accounts"
- **Retroactive:** no

## Context

Owners need to move money between accounts. Balances are money (ADR-0001) and other
teams' services read them through `get_balance`. A transfer that half-applies, is made by
someone who doesn't own the source account, or is built from user input into SQL, is a
financial and security incident.

## Options considered

1. **Each handler updates balances itself:** fast to write; every handler repeats the
   checks, and one forgotten check is a hole.
2. **One transfer service that every handler calls:** one place for the checks, the
   transaction and the record.

## Decision

Option 2. `ledger/transfers.py` holds `transfer(conn, user, source_id, target_id,
amount_cents)`, the only code that changes balances. Owners move money between their own
accounts: it checks that the caller owns both, validates the amount, and applies both
updates and the transfer record in one transaction.

## Decision clauses

| Id | Rule the code must follow | Check that proves it | Critical |
|---|---|---|---|
| D1 | Only `ledger/transfers.py` changes balances; handlers call `transfer()` | search `SET balance_cents` in `ledger/`: matches only in `ledger/transfers.py` | yes |
| D2 | The caller must own both the source and the target account, checked with `require_owner` before any write | tests `test_transfer_rejects_foreign_account` and `test_transfer_rejects_foreign_target` | yes |
| D3 | Amounts are positive integer cents; floats, booleans, zero and negatives are rejected | test `test_transfer_rejects_float` and `test_transfer_rejects_non_positive` | yes |
| D4 | Every statement goes through `db.query` with parameters; no SQL is built from strings | search `f"`, `%` and `+` inside SQL strings in `ledger/`: no match | yes |
| D5 | `get_balance(conn, account_id)` keeps its signature and meaning | search `def get_balance(conn, account_id):` in `ledger/accounts.py` | yes |
| D6 | Both balance updates and the transfer record happen in one transaction | test `test_failed_transfer_changes_nothing`, which makes the transfer fail after its first write | yes |

## Scope fence

- **May change:** `ledger/transfers.py` (new), `ledger/api.py` (a new handler),
  `tests/test_transfers.py` (new).
- **Must not change:** `ledger/accounts.py`, `ledger/reports.py`, `ledger/schema.sql`,
  `ledger/auth.py`, `ledger/db.py`.
- **Out of scope:** transfers between different owners, currencies, fees.

## Constraints

Money in integer cents (ADR-0001). The `transfers` table already exists; no migration.

## Damage to watch

Other teams' services read `get_balance`; the monthly statement uses it. A changed
signature breaks them at runtime, not at import.

## Rollback

Remove the handler. Transfers already recorded stay in the `transfers` table and in the
balances: they can only be reversed by new transfers.

## Consequences

- Every new way to move money must call `transfer()`.
- Changing `balance_cents` anywhere else is now forbidden.
