---
name: product-brief
description: Turns the market report and the offer into a product requirements document and a design brief, run by hand with /coderachnid:product-brief "product". Reads docs/MARKET.md, docs/OFFER.md and the user's own references, and writes docs/PRD.md (what is being built, for whom and where, the problem, core features and how each works, stories with acceptance criteria, personal data and threats, entities, frozen MVP scope) and docs/BRIEF.md (a design direction and a detailed mockup prompt), ready for F0.
disable-model-invocation: true
argument-hint: "[product]"
arguments: [product]
---

# Product brief

The decision to make: **what must the first version do, for whom, and what does it look
like, in enough detail that design and code can start without guessing?**
Product: $product.

> **Measured** (2026-11-17, fictional product): every section of both documents in 2 of
> 2 runs; a loose prompt for the same two documents scored 0.32. **Used on one real
> project**, which is where the split into two documents and the rules marked *(field)*
> come from. Record what fails in `pitfall-log`.

Write in the user's language. If the product argument is missing, take it from
`docs/OFFER.md` and confirm it with the user.

## Gather first, in one message

- **Read `docs/MARKET.md` and `docs/OFFER.md`.** If either is missing, say so and
  recommend running the earlier links (`/coderachnid:market-research`, then
  `/coderachnid:offer`). If the user goes on anyway, label what rests on no evidence as
  ASSUMPTION. If the report is weeks old, re-check its substitutes and competitors first.
- **Look for the user's own material in the repository first** (brand notes, logo
  files, a `docs/` or `brand/` folder), then ask only for what is missing, all in one
  question: logo, typefaces, colors, pages or apps they like and why, things they
  dislike, and any brand rules. **Their taste always wins over this skill's defaults**;
  where they give nothing, the brief proposes, and says it is a proposal.

## Two documents, requirements first

Requirements go in `docs/PRD.md` and design in `docs/BRIEF.md`. In a first real brief
they shared one file: the design was revised five times and grew to 750 lines, with the
requirements behind it, where nobody building would read them.

## Part A · Product requirements → `docs/PRD.md`

Read `references/prd-structure.md` first and follow its sections, ids and wording
rules. In short:

1. **What we are building**, in one paragraph without adjectives, and what it is not.
2. **Who it is for and where it applies:** the first customer from the market report,
   the situation that triggers use, device and platform, regions and languages, and who
   it is not for.
3. **The problem**, with its evidence rows from the market report and the cost of
   today's workaround. Each claim keeps the verdict the report gave it.
4. **Goals, success metrics and non-goals**: each metric with a number and how it is
   measured.
5. **Core features** as a table: id · feature · problem it serves · priority (Must,
   Should, Later) · how it works in one line. The Musts are the fewest that solve the
   first problem from start to finish.
6. **How it works:** each main journey as numbered steps (the user does · the system
   does · the user sees), with the first run and what happens when a step fails.
7. **User stories with acceptance criteria.** *As [user], I want [action], so that
   [outcome]*, each with criteria in *Given / When / Then* form, including at least one
   failing path. Each criterion becomes a test (see `tests-that-bite`).
8. **Quality requirements** with numbers: speed, accessibility, platforms, languages.
9. **Personal data and threats.** Every piece of personal data the MVP touches: why it is
   needed, where it lives, how long it is kept, who can see it. Then the main threats and
   the control for each (see `security-first`). Data that isn't needed is not collected.
10. **Entities:** the main entities, their key fields, relations and who owns each
    record; which fields are figures that need a source (see `sourced-data`). The
    starting point for the schema and its first migration (see `safe-database`).
11. **Frozen MVP scope:** *in* (each item is a feature id) and *explicitly not in*. It
    becomes the plan's frozen scope for F0 (see `phased-plan`).
12. **Assumptions, risks and open questions**, each with its test or its owner and date.
13. **Traceability:** problem → feature → story, one table. A row with a gap is fixed
    or cut.

## Part B · Design direction → `docs/BRIEF.md`

Read `references/art-directed-editorial.md` before writing this part.

1. **What the competitors look like.** For the five main competitors in the market
   report: palette, type, hero imagery, layout, tone. If the report doesn't record it,
   look at their sites with web tools or ask the user for screenshots; never invent it.
   Name the **category default** (the look most of them share) and the **free visual
   position**, the look nobody in the category uses that still fits the customer.
2. **Branding skeleton.** Built on the user's material when given; otherwise proposed:
   the family from the reference and why it fits the niche and stands apart from the
   competitors, a type pairing, a palette of neutrals plus **one accent** (hex values,
   contrast checked), the hero visual concept, and one signature detail.
3. **Layout, section by section**, for desktop and mobile: what each section says, which
   element leads, the one primary call to action, and the states of every key screen
   (empty, loading, error, success). Screens show the PRD's features by their ids; copy
   uses the value proposition from the offer.
4. **The mockup prompt.** One self-contained prompt that describes every element (canvas
   and breakpoints, grid, type with sizes, colors with hex, the hero visual, each section
   in order, the call to action, the signature detail, the texture) so a design skill or
   an image generator can produce the mockup without reading anything else. Polishing
   is the design tool's job; the brief fixes direction, not pixels.
5. **Guardrails**, stated in the brief:
   - social proof (user counts, "trusted by", client logos, testimonials) is a **marked
     placeholder** until it is real;
   - text over images and glass over busy backgrounds passes WCAG 2.2 AA contrast;
   - the hero visual has a load budget (weight and time on a mid-range phone), and
     motion respects reduced-motion settings;
   - generated art is original, and the references are never reused as assets.

## Rules

- **Trace everything back.** Every feature, screen, story and entity points to a top
  problem or to the offer; what points nowhere is not in the MVP.
- **One primary action per screen.** If a screen needs two, it is two screens or one is
  secondary.
- **No figure on screen without its source**, in the mockup copy too: placeholder
  figures are marked as such.
- **When the owner changes direction, rewrite the section** and add a dated line to the
  document's change log. Never stack "version 2, which overrides version 1 where they
  differ" on top: the reader then has to merge them, and each will merge differently.
- **The design never adds a feature.** A screen that needs something the PRD lacks sends
  the question back to the PRD.

## Afterwards

- Save `docs/PRD.md` and `docs/BRIEF.md`, dated. Keep the mockup prompt in a fenced
  block so it can be copied whole.
- Hand the mockup prompt to the user's design skill or image generator, then review the
  mockup against the brief as a table before building (see `phased-plan`).
- With the owner's "go", `project-setup` and `phased-plan` turn the PRD's frozen scope
  and stories into the plan's F0. After that the PRD changes only by decision: a dated
  line in its change log, and an ADR when the scope moves.
