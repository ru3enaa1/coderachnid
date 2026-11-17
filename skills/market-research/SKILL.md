---
name: market-research
description: Idea validation and market research before a project starts, run by hand with /coderachnid:market-research "idea or problem" "customer" "industry" "regions". Frames the idea as a problem, finds people already describing it in open communities and reviews, finds products that already earn money from it, sizes the market, ranks the top ten problems, maps the five main competitors and the free position, every figure and quote with a source, and ends with a verdict per claim, the riskiest assumptions and the cheapest test for each.
disable-model-invocation: true
argument-hint: "[idea or problem] [customer] [industry] [regions]"
arguments: [idea, customer, industry, regions]
---

# Market research

The decision to make: **is it worth building $idea for $customer?**
Market: $industry · Regions: $regions.

Write the report in the user's language. If an argument is missing, ask for it before
starting. Use web search and read the pages themselves; if web tools are not available,
say so and deliver only the research plan, with no figures (see `sourced-data`).

## Frame the problem before searching

- **Restate the idea as a problem:** *[who] can't [do what] when [situation]; today they
  [workaround], and it costs them [time, money or risk].* Research the problem, not the
  solution. An idea with no problem behind it is researched as a hypothesis, and said so.
- **If the user lives the problem, interview them first** about the last time it
  happened: when, what they did, what it cost, what they tried or paid for, how often.
  That is one data point: a FACT about one person, an ASSUMPTION about the market.
- **Split the idea into claims** and validate each on its own: the problem exists · these
  people have it · they already spend on it · this solution is what they want. A first
  real report validated the market around an idea and left the idea's own core feature at
  "no data"; read quickly, it looked validated.
- **Write the "don't build" signals now**, before any search. A bar set after seeing the
  data always fits the data.
- **No idea yet, only a field?** Run step 2 first across the customer's communities,
  cluster the complaints, and propose three candidate problems with their evidence.
- **In a field that can be misused** (security, health, money), state in the first line
  who uses the product, where and with whose permission, and keep that framing in every
  search. Vague wording stalled the research of a training product.

## Evidence rules

- **Every figure carries a source (link), a date and a range.** Prefer primary sources:
  official statistics, regulators, annual reports, public filings. Never the search
  engine's summary or an AI overview.
- **A quote comes from a page opened in this session**, copied exactly, with its link
  and date. Never from a search snippet, never rebuilt from memory. A page that can't be
  opened is listed as "not opened"; ask the user to open it and paste the thread. Many
  communities block automated readers: never work around a block.
- **When sources disagree, show both.** When there is no source, write "no data" and say
  how it could be measured.
- **Report sellers are the weakest source for market size.** Two of them sized one niche
  at 2.8 and at 6.3 billion. Mark them SECONDARY and lead with a bottom-up built from
  products whose revenue is known (step 3).
- **Label every claim** as FACT, ESTIMATE (with its method) or ASSUMPTION.

## Deliver, in this order, without padding

Method for steps 2 and 3: read `references/demand-signals.md` before starting them.

1. **The problem and its claims**, as framed above, with the "don't build" signals.
2. **Demand signals:** people describing the problem in their own words. Cover at least
   three kinds of places, one of them a community where the customer talks to peers (a
   forum, a subreddit, a group), not only review sites: a first real report quoted review
   sites alone and never heard the customer talking. A table: quote · link · date · place
   · signal strength. Count independent authors, list at least five unmet needs with how
   often each appears, and include the evidence against.
3. **Proven demand:** products that already earn money from this problem or the one next
   to it. For each: what they charge for, price, revenue or downloads with the provider,
   whether the figure is gross or net, its date, and how reliable it is. Then the model
   worth adapting and the one variable to change (segment, region, language, price,
   channel).
4. **Definition:** what is in the market and what is not; the main segments.
5. **Size and growth:** TAM, SAM and SOM, each top-down and bottom-up, with the method
   shown; growth with its period. The bottom-up starts from step 3.
6. **Five demand drivers:** trend → evidence → what it means for the idea.
7. **Top ten problems**, as a table ranked by urgency × willingness to pay:

   | # | Problem | Who has it | Urgency 1–5 | Willingness to pay | Trend |
   |---|---|---|---|---|---|

   - **Urgency** comes with its evidence from step 2: a quote, a complaint count, a
     regulation date. A score without evidence is an ASSUMPTION and says so.
   - **Willingness to pay** is read from what people already spend on workarounds and
     substitutes (tools, staff hours, agencies, fines), not from what they say they
     would pay.
   - **Trend** is ↑, → or ↓ with a source (search volume, job postings, complaint
     counts over time). Mark the **three fastest growing**.
8. **Competition:** the substitutes people use instead (general-purpose tools included:
   they are often the real competitor), then the **five main competitors**, each with
   what they do better, where they are weak, two quoted reviews with source, the customer
   they ignore, their price, and how their home page looks (palette, imagery, type,
   tone), which `product-brief` uses. Then:
   - a **positioning map** on the two axes that matter most to the customers found in
     steps 2 and 7 (for example price × depth, or self-serve × done-for-you), with every
     competitor placed and the reason for each placement;
   - **the free position**: the quadrant or segment nobody serves well, and the
     evidence that someone wants it.
9. **Where money is moving** (last 24 months): funding rounds, acquisitions, ad spend,
   job postings, public tenders.
10. **Barriers and risks:** regulation, platform rules, sales channels, acquisition cost.
11. **Validation scorecard:** one row per claim from step 1: evidence for · evidence
    against · verdict (VALIDATED, PARTLY, NOT YET or CONTRADICTED). A verdict rests only
    on evidence in this report; "no data" is NOT YET, never a pass.
12. **Conclusions:** the opportunity in one sentence, the ideal first customer, the
    entry wedge (which top problem, from which free position), an indicative price, which
    "don't build" signals fired, and the **three riskiest assumptions, each with the
    cheapest test to run this week**: the NOT YET rows come first.
13. **Sources table:** claim · source · date · primary or secondary · opened or not.

## Afterwards

- Save the report as `docs/MARKET.md`, dated, with its sources table.
- Add the three riskiest assumptions and their tests to the plan's discovery phase (see
  `phased-plan`). Building starts when the owner decides "go" on that evidence. If the
  owner builds first, the tests are deferred, not dropped, and their thresholds stay.
- The report has a date: substitutes change (a general-purpose tool gained the idea's
  main feature weeks after one report). Re-check steps 3 and 8 before the next link.
- The next link of the chain is `/coderachnid:offer`, which reads this file. Suggest
  running it in a fresh session (see `handoff`), not in this one.
