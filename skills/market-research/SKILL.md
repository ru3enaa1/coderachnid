---
name: market-research
description: Market research before a project starts, run by hand with /coderachnid:market-research "idea" "customer" "industry" "regions". Sizes the market, finds demand drivers, competitors, unmet needs from real reviews and where money is moving, every figure with a source, and ends with the riskiest assumptions and the cheapest test for each.
disable-model-invocation: true
argument-hint: "[idea] [customer] [industry] [regions]"
arguments: [idea, customer, industry, regions]
---

# Market research

The decision to make: **is it worth building $idea for $customer?**
Market: $industry · Regions: $regions.

Write the report in the user's language. If an argument is missing, ask for it before
starting. Use web search and read the pages themselves; if web tools are not available,
say so and deliver only the research plan, with no figures (see `sourced-data`).

## Evidence rules

- **Every figure carries a source (link), a date and a range.** Prefer primary sources:
  official statistics, regulators, annual reports, public filings. Never the search
  engine's summary or an AI overview.
- **When sources disagree, show both.** When there is no source, write "no data" and say
  how it could be measured.
- **Label every claim** as FACT, ESTIMATE (with its method) or ASSUMPTION.

## Deliver, in this order, without padding

1. **Definition:** what is in the market and what is not; the main segments.
2. **Size and growth:** TAM, SAM and SOM, each top-down and bottom-up, with the method
   shown; growth with its period.
3. **Five demand drivers:** trend → evidence → what it means for the idea.
4. **Competition:** five to ten players and the substitutes people use instead, with
   price, proposition and a visible weakness.
5. **Five unmet needs from real reviews and complaints** (app stores, review sites,
   forums, social media): a quoted line, its source and how often it appears.
6. **Where money is moving** (last 24 months): funding rounds, acquisitions, ad spend,
   job postings, public tenders.
7. **Barriers and risks:** regulation, sales channels, customer acquisition cost.
8. **Conclusions:** the opportunity in one sentence, the ideal first customer, the
   entry wedge, an indicative price, the signals that would mean "don't build", and the
   **three riskiest assumptions, each with the cheapest test to run this week**.
9. **Sources table:** claim · source · date · primary or secondary.

## Afterwards

- Save the report as `docs/MARKET.md`, dated, with its sources table.
- Add the three riskiest assumptions and their tests to the plan's discovery phase (see
  `phased-plan`). Building starts when the owner decides "go" on that evidence.
