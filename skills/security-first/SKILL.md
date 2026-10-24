---
name: security-first
description: Use whenever code touches untrusted input or sensitive data, small changes included: adding or changing any endpoint or route (even one that only edits a field), a form, file upload, import, query, authentication, session or permission, secrets or personal data; at the start of each phase; and before every commit. Applies threat modeling, trust boundaries, input validation, secret handling, safe logging and a pre-commit security checklist so security is designed in, not bolted on at the end.
---

# Security first

Security is a design input, not a review step. Every phase starts by asking what can
go wrong and ends by proving that each control works. **A control without a test is a
wish.**

## When a phase, feature or endpoint starts

1. **Name the assets.** What is being protected: personal data, customer files,
   secrets, money, the user's machine.
2. **Draw the trust boundaries.** Every place where data crosses from untrusted to
   trusted: user input, uploaded or imported files, configuration and knowledge files,
   network responses, third-party libraries, AI model output.
3. **Run STRIDE on each boundary** (Spoofing, Tampering, Repudiation, Information
   disclosure, Denial of service, Elevation of privilege). Write the threats and their
   controls in the plan or in an ADR, not only in the conversation.
4. **Check the current OWASP Top 10** against the feature, item by item, and fit it to
   the real threat model: rate limiting or CORS rules written for public services may
   not apply to a single-user local app, while host checks and one-time tokens do.
5. **Give every control its test** (see `tests-that-bite`): no token → rejected,
   foreign `Host` → rejected, missing CSRF → rejected, log contains no customer data.
   Those tests are the phase's acceptance criteria: the phase is not done until they pass.

## Rules that do not bend

- **Secrets** live in environment variables or the OS keychain. Never in the
  repository, logs, error messages, fixtures, screenshots or user data files. Check that
  they are present at startup. An unresolved placeholder (`${API_KEY}`) must fail
  loudly, never become the literal value.
- **Least exposure.** A local app binds to `127.0.0.1`, uses an ephemeral port and a
  one-time token. Remote access is a requirement you write down, never a default.
- **Everything external is hostile:** input, files, imports, API responses, LLM output.
  Validate at the boundary, with length limits equal to the database constraints.
- **No expression evaluators on data.** No `eval`, no scripting engines, no dynamic
  expression languages, no reflection driven by input. Conditions are data structures;
  logic is tested code.
- **Parameterized queries only.** No SQL built by string concatenation.
- **Encode output by default.** Never render unescaped user content. Strict CSP: no
  inline scripts and no inline `style=""`, including inside inline SVG.
- **CSRF on every state-changing request.** Prove that a request without the token is
  rejected.
- **Logs carry no personal or customer data.** Check what your libraries log too:
  migration tools and ORMs often print connection URLs and file names, which can contain
  a customer's name. Turn those loggers down, also on code paths that run without the
  framework (a terminal command), where its logging configuration is never read.
- **Never swallow an exception** or flatten it into a generic error that hides the
  cause, and never leak internals to the end user.
- **Privacy by design:** counts, not contents; roles, not people. No surveillance
  (keystrokes, screenshots, reading messages) unless that is the explicit, consented
  product. Sensitive categories (health, children, finance) get the strictest reading
  of the applicable law.
- **Nothing leaves the machine** without explicit, per-feature, revocable consent.
- **Dependencies** enter one at a time, in the phase that needs them, with the version
  verified that day (how: `precise-code`). Scan them (SCA) and keep an SBOM.
- **Distribute signed artifacts** and publish their checksums.

## Pre-commit checklist

- [ ] No secret in code, logs or error messages.
- [ ] No customer or personal data in technical logs.
- [ ] Every new input validated at the boundary, with limits equal to the DB constraints.
- [ ] No concatenated SQL, no unescaped output, no inline script or style.
- [ ] Every new state-changing request has CSRF, and a test proves it rejects without it.
- [ ] No `catch` that swallows or hides the cause.
- [ ] External content (files, imports, knowledge data, AI output) treated as hostile.
- [ ] No expression evaluator or input-driven reflection.
- [ ] Any migration is non-destructive and tested from the previous version.
- [ ] Network exposure unchanged (still loopback-only, if that is the design).
- [ ] On a public repository, commits use a no-reply author email. Every commit stores
      it, so a personal address is published with the first push.
- [ ] What is staged is exactly what was meant (`git diff --cached --stat`), above all
      after `git add -A`, which also picks up stray files.
- [ ] Full build and test suite green, confirmed by the **exit code**.

## References

- `references/local-web-app.md`: hardening a web server that runs on the user's own machine.
- `references/llm-integration.md`: calling an AI model without leaking data or trusting its output.
