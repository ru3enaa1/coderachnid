---
name: market-research
description: Market research before a project starts, run by hand with /coderachnid:market-research "idea" "customer" "industry" "regions". Sizes the market, finds demand drivers, unmet needs from real reviews, the top ten problems ranked by urgency and willingness to pay, the five main competitors on a positioning map with the free position, and where money is moving, every figure with a source, and ends with the riskiest assumptions and the cheapest test for each.
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
4. **Five unmet needs from real reviews and complaints** (app stores, review sites,
   forums, social media): a quoted line, its source and how often it appears.
5. **Top ten problems**, as a table ranked by urgency × willingness to pay:

   | # | Problem | Who has it | Urgency 1–5 | Willingness to pay | Trend |
   |---|---|---|---|---|---|

   - **Urgency** comes with its evidence: a quote, a complaint count, a regulation date.
     A score without evidence is an ASSUMPTION and says so.
   - **Willingness to pay** is read from what people already spend on workarounds and
     substitutes (tools, staff hours, agencies, fines), not from what they say they
     would pay.
   - **Trend** is ↑, → or ↓ with a source (search volume, job postings, complaint
     counts over time). Mark the **three fastest growing**.
6. **Competition:** the substitutes people use instead, then the **five main
   competitors**, each with what they do better, where they are weak, two quoted
   reviews with source, the customer they ignore, and their price. Then:
   - a **positioning map** on the two axes that matter most to the customers found in
     steps 4 and 5 (for example price × depth, or self-serve × done-for-you), with every
     competitor placed and the reason for each placement;
   - **the free position**: the quadrant or segment nobody serves well, and the
     evidence that someone wants it.
7. **Where money is moving** (last 24 months): funding rounds, acquisitions, ad spend,
   job postings, public tenders.
8. **Barriers and risks:** regulation, sales channels, customer acquisition cost.
9. **Conclusions:** the opportunity in one sentence, the ideal first customer, the
   entry wedge (which top problem, from which free position), an indicative price, the
   signals that would mean "don't build", and the **three riskiest assumptions, each
   with the cheapest test to run this week**.
10. **Sources table:** claim · source · date · primary or secondary.

## Afterwards

- Save the report as `docs/MARKET.md`, dated, with its sources table.
- Add the three riskiest assumptions and their tests to the plan's discovery phase (see
  `phased-plan`). Building starts when the owner decides "go" on that evidence.
- The next link of the chain is `/coderachnid:offer`, which reads this file. Suggest
  running it in a fresh session (see `handoff`), not in this one.
