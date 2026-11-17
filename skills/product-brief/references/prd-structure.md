# The product requirements document (PRD)

The structure of `docs/PRD.md`. It is the contract between the evidence (market report
and offer) and the code: someone who reads only this file knows what to build, for whom,
why, and how to tell when it is done. Sections keep this order and these numbers, so
that "PRD §5, F3" always means the same place.

Rules marked *(field)* come from a real brief this skill produced; the rest are
**anticipated** until a real project confirms or corrects them.

## Header

Product · PRD version · date · status (DRAFT, or APPROVED by the owner on a date) ·
the reports it was built from, with their dates.

## 1. What we are building

One paragraph a stranger can repeat: what it is, what the user does with it and what
they get. No adjectives ("simple", "powerful", "smart") and no technology names. Then
one line: **what it is not**. *(field)* A product that guides practice on other
companies' platforms had to say "it does not host the exercises", or readers kept
budgeting for hosting.

## 2. Who it is for and where it applies

- **First customer**, from the market report's conclusions, in one sentence. Other
  segments are listed as later, not served by the MVP.
- **Where it applies:** the situation that triggers use (what the person is doing just
  before), device and platform, connected or offline, regions and languages, how often.
- **Who it is not for**, and any use the product must refuse.

## 3. The problem

The problem sentence from the market report, then its evidence: the rows of the
top-problems table it rests on, two or three quotes with their links, and what today's
workaround costs. Each claim keeps the report's verdict (VALIDATED, PARTLY, NOT YET).
*(field)* When the owner chooses to build before validating, the PRD says so here and
lists the deferred tests with their thresholds unchanged: the risk was accepted, not
removed.

## 4. Goals, success metrics and non-goals

- One to three outcomes for the user. For each, a **metric with a number**, its starting
  value when known, the target, and how and when it is measured.
- **Non-goals:** what this version deliberately does not try to achieve.

## 5. Core features

| Id | Feature | Problem it serves | Priority | How it works, in one line |
|---|---|---|---|---|

- Ids are F1, F2… and never reused. Priority is **Must**, **Should** or **Later**.
- **The Musts are the fewest that solve the first problem from start to finish.** More
  than about five Musts is a sign the MVP is not minimal: justify each or demote it.
- A feature that serves no problem row is cut. A feature whose problem is NOT YET
  validated is marked ASSUMPTION.

## 6. How it works

Each main journey as numbered steps, three columns: **the user does · the system does ·
the user sees**. Cover:

- the first run (nothing saved yet);
- the main journey of each Must feature, start to finish;
- what happens when a step fails: invalid input, no connection, an empty result, a
  refusal.

Every step names the feature id it belongs to. A step that needs something not in §5
means §5 is incomplete: fix the table, not the journey.

## 7. User stories and acceptance criteria

- Ids US-1, US-2…: *As [user], I want [action], so that [outcome]*, with the feature id.
- Criteria AC-1.1, AC-1.2… in *Given / When / Then* form, at least one failing path per
  story. Each criterion becomes a test and keeps its id in the test's name.

## 8. Quality requirements

Measurable, never adjectives: response time on a named device, accessibility level,
supported platforms and browsers, languages, availability, what must work offline.

## 9. Personal data and threats

A table of every piece of personal data (why · where it lives · how long · who sees it)
and a table of threats with the control for each. Data that isn't needed is not
collected.

## 10. Entities

Main entities, key fields, relations, who owns each record, and which fields are
figures that need a source.

## 11. Frozen MVP scope

**In:** the Must features, by id. **Explicitly not in:** what someone will ask for, with
the reason. **Later:** the Should and Later features, unscheduled.

## 12. Assumptions, risks and open questions

Each assumption with the test that would settle it; each risk with what would be done;
each question with who answers it and by when.

## 13. Traceability

| Problem (market report row) | Feature | Stories | Verified by |
|---|---|---|---|

One row per Must feature. An empty cell is a gap: fill it or cut the row.

## 14. Change log

Date · what changed · why · who decided. Once the owner approves the PRD, every change
lands here; a change of scope also gets an ADR.

## Wording rules

- **One requirement per line, with an id**, so a test, a commit or a question can point
  at it.
- **"Must" states a requirement; "should" a preference.** Use them on purpose.
- **Words that can't be tested are replaced by a number or removed:** fast, easy,
  intuitive, modern, secure, scalable, user-friendly, robust, seamless.
- **Say what, not how.** The stack and the architecture belong in ADRs; the look
  belongs in the brief.
- **Rewrite, don't stack.** A changed decision replaces the old text and leaves a line
  in the change log. *(field)* A document that kept "direction v2, which overrides v1
  where they differ" above the original left every reader to do the merge.
- **Short enough to read in one sitting.** What grows beyond that moves to its own
  document and is linked.
