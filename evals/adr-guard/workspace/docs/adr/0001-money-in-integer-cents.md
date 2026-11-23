# ADR-0001 · Money is stored and moved in integer cents

- **Date:** 2026-10-02 · **Status:** accepted

## Context

Balances are read by other teams' services and printed on statements. Binary floating
point can't represent most decimal amounts exactly, and a rounding error in a balance is a
financial error.

## Decision

Every amount is an integer number of cents, in storage, in code and at every API
boundary. Conversion to a decimal string happens only when printing.

## Decision clauses

| Id | Rule the code must follow | Check that proves it | Critical |
|---|---|---|---|
| D1 | Amount columns are `INTEGER` | `ledger/schema.sql`: every `*_cents` column is `INTEGER` | yes |
| D2 | No `float` is used for an amount in `ledger/` | search `float(` and `* 100` in `ledger/`: no match on an amount | yes |
