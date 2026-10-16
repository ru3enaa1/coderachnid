---
name: sourced-data
description: Use when a product shows figures that people will rely on, or when writing them: prices, costs, statistics, benchmarks, thresholds, research findings, regulations or market data. Requires a primary source, date and range for every figure, rejects search-engine summaries and contradicting aggregators, and says "no source, no number" instead of inventing one.
---

# Sourced data

A figure on screen is a promise. If nobody can say where it came from, the product is
guessing in the user's name. This skill applies wherever numbers or claims reach users:
in the UI, in reports, in knowledge files, in help pages.

## Every figure carries its source

- **Source, date, range.** Store the figure with where it came from (a URL or a
  document reference), when it was retrieved, and its range or uncertainty. A single
  number without a range claims a precision nobody measured.
- **Keep the source next to the data**, as fields of the same record, not in a separate
  note that drifts. A test checks that no figure is missing them.
- **Mark design assumptions as assumptions.** A default the team chose is labeled as a
  choice, never presented as a finding.

## Read the primary source

- **Never trust the search engine's summary or an AI overview.** Open the study, the
  official page or the regulation itself. Summaries get authors, years and numbers
  wrong: one attributed a meta-analysis to the wrong author until the paper was read.
- **Aggregators that contradict each other are discarded.** When price comparisons or
  blog round-ups disagree, go to the official pages they claim to summarize.
- **Quote rules exactly.** For laws, standards and terms of service, keep the article
  or clause number and the exact wording, not a paraphrase.

## No source, no number

- If no serious source exists, **say so and don't invent one.** Leave the field empty,
  mark it to be measured in the field, and tell the owner.
- **A model never produces a figure that must be correct.** Figures come from data or
  from a deterministic, tested formula; a model may explain them, never compute them
  (see `../security-first/references/llm-integration.md`).

## Keep it fresh

- **Every figure has a review date.** Prices, rates and regulations change; a test or a
  report lists the ones past their date.
- When a figure changes, **record the old value, the new one and why**, so results
  produced before the change can still be explained.

## Checks

- [ ] Every figure in data has source, retrieval date and range (enforced by a test).
- [ ] Each source was opened directly, not read through a summary.
- [ ] Contradicting secondary sources were replaced by the primary one.
- [ ] Gaps are marked as gaps, not filled with plausible numbers.
- [ ] Design assumptions are labeled as such.
