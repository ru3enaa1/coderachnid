---
name: product-brief
description: Turns the market report and the offer into a product brief, run by hand with /coderachnid:product-brief "product". Reads docs/MARKET.md, docs/OFFER.md and the user's own references, and writes docs/BRIEF.md with a design direction and a detailed mockup prompt, plus system requirements (stories with acceptance criteria, personal data and threats, entities, frozen MVP scope) ready for F0.
disable-model-invocation: true
argument-hint: "[product]"
arguments: [product]
---

# Product brief

The decision to make: **what does the first version look like and what must it do, in
enough detail that design and code can start without guessing?** Product: $product.

> **Anticipated:** these rules were written from practice elsewhere and have not yet
> been used on a real project with this plugin. Record what fails in `pitfall-log`.

Write in the user's language. If the product argument is missing, take it from
`docs/OFFER.md` and confirm it with the user.

## Gather first, in one message

- **Read `docs/MARKET.md` and `docs/OFFER.md`.** If either is missing, say so and
  recommend running the earlier links (`/coderachnid:market-research`, then
  `/coderachnid:offer`). If the user goes on anyway, label what rests on no evidence as
  ASSUMPTION.
- **Ask for the user's own material**, all in one question: logo, typefaces, colors,
  pages or apps they like and why, things they dislike, and any brand rules. **Their
  taste always wins over this skill's defaults**; where they give nothing, the brief
  proposes, and says it is a proposal.

## Part A · Design direction

Read `references/art-directed-editorial.md` before writing this part.

1. **What the competitors look like.** For the five main competitors in the market
   report: palette, type, hero imagery, layout, tone. Name the **category default** (the
   look most of them share) and the **free visual position**, the look nobody in the
   category uses that still fits the customer.
2. **Branding skeleton.** Built on the user's material when given; otherwise proposed:
   the family from the reference and why it fits the niche and stands apart from the
   competitors, a type pairing, a palette of neutrals plus **one accent** (hex values,
   contrast checked), the hero visual concept, and one signature detail.
3. **Layout, section by section**, for desktop and mobile: what each section says, which
   element leads, the one primary call to action, and the states of every key screen
   (empty, loading, error, success). Copy uses the value proposition from the offer.
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

## Part B · System requirements

6. **User stories with acceptance criteria.** *As [user], I want [action], so that
   [outcome]*, each with criteria in *Given / When / Then* form, including at least one
   failing path. Each criterion becomes a test (see `tests-that-bite`). Each story names
   the top-problem row it serves; a story that serves none is cut.
7. **Personal data and threats.** Every piece of personal data the MVP touches: why it is
   needed, where it lives, how long it is kept, who can see it. Then the main threats for
   this product and the control for each (see `security-first`). Data that isn't needed
   is not collected.
8. **Entities.** The main entities, their key fields, their relations and who owns each
   record; which fields are figures that need a source (see `sourced-data`). This is the
   starting point for the schema and its first migration (see `safe-database`).
9. **Frozen MVP scope.** Two lists: *in* (each item traced to a story) and *explicitly
   not in*. This becomes the plan's frozen scope for F0 (see `phased-plan`).
10. **Open questions**, each with who answers it and by when.

## Rules

- **Trace everything back.** Every screen, story and entity points to a top problem or
  to the offer; what points nowhere is not in the MVP.
- **One primary action per screen.** If a screen needs two, it is two screens or one is
  secondary.
- **No figure on screen without its source**, in the mockup copy too: placeholder
  figures are marked as such.

## Afterwards

- Save as `docs/BRIEF.md`, dated. Keep the mockup prompt in a fenced block so it can be
  copied whole.
- Hand the mockup prompt to the user's design skill or image generator, then review the
  mockup against the brief as a table before building (see `phased-plan`).
- With the owner's "go", `project-setup` and `phased-plan` turn the frozen scope and the
  stories into the plan's F0.
