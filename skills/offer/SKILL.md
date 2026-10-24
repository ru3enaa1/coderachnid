---
name: offer
description: Turns market evidence into an offer, run by hand with /coderachnid:offer "product" after market research. Reads docs/MARKET.md and writes docs/OFFER.md with a one-sentence value proposition, three price tiers anchored to competitor prices, a guarantee that can be honored, why it wins from the free position, the cheapest test of the offer, and the promises the product must never make.
disable-model-invocation: true
argument-hint: "[product]"
arguments: [product]
---

# Offer

The decision to make: **what exactly do we sell to whom, at what price, and how do we
find out cheaply whether they buy it?** Product: $product.

> **Anticipated:** these rules were written from practice elsewhere and have not
> yet been used on a real project with this plugin. Record what fails in `pitfall-log`.

Write in the user's language. If the product argument is missing, take the idea from
`docs/MARKET.md` and confirm it with the user.

## Start from the evidence

- **Read `docs/MARKET.md` first.** If it doesn't exist, say so and recommend
  `/coderachnid:market-research` before this. If the user wants to go on anyway, every
  price, problem and competitor in the offer is labelled ASSUMPTION.
- **Cite the market report by row.** Each choice below names the top-problem row, the
  competitor or the source it rests on, so the offer can be checked against the
  evidence and updated when the evidence changes.
- **Label every claim** as FACT, ESTIMATE (with its method) or ASSUMPTION, as in the
  market report (see `sourced-data`).

## Deliver, in this order

1. **Value proposition in one sentence:**
   *For [customer] who [problem], [product] achieves [outcome], unlike [alternative].*
   The customer and problem come from the top-problems table, the alternative from the
   substitutes or competitors. The outcome is one the product controls. Check: someone
   who never saw the project can repeat it after reading it once.
2. **Three price tiers.** For each: who it is for, what it includes, what it leaves out,
   the price in the regions' currencies with taxes stated, and the **anchor**: the
   competitor price or the current spend on workarounds it is compared to, with the
   source row. Every price is **ASSUMPTION until tested**. The middle tier is the one
   the offer is built to sell; say why.
3. **Guarantee.** One guarantee the team can actually honor: state what triggers it, what
   the customer gets, and what it would cost if a quarter of customers claimed it. It
   must be legal in every region: name the consumer rules that apply (statutory
   withdrawal or refund periods, rules on "free" trials and automatic renewals) with
   their source, and say "to be confirmed by a lawyer" where the rule is unclear. Never
   guarantee an outcome the product doesn't control.
4. **Why it wins.** Tie it to the **free position** from the market report: which
   customers move, from which competitor or substitute, and why. Then say what a
   competitor would have to change to copy it, and how long that would take them.
5. **The cheapest test of the offer**, runnable this week: a landing page with the real
   price and a pre-order or waitlist, a "fake door" in an existing channel, a manual
   (concierge) delivery for the first customers, or ten interviews ending in a price
   question. Set the **success threshold before running it** (for example "5 of 50
   visitors leave a deposit") and the date it is read.
6. **Promises the product must never make.** A plain list, one phrase per line, for the
   project's `check-forbidden-phrases.sh` guard (see `project-setup`): outcome
   guarantees ("guaranteed results", "100% accurate"), "risk-free", absolute claims
   ("never", "always", "the only"), regulated claims for the niche (health, returns,
   legal advice) and social proof that doesn't exist yet ("trusted by", "+10,000
   users"). Each phrase with the reason in a comment line above it.

## Rules

- **No price without an anchor.** A tier whose price can't point to a competitor price
  or a measured current spend is not ready; say what to measure.
- **No invented social proof.** Testimonials, logos and user counts appear only when
  real; until then they are marked placeholders.
- **The offer serves the first customer**, the one named in the market report's
  conclusions, not every segment at once.

## Afterwards

- Save as `docs/OFFER.md`, dated, with a sources section that points back to
  `docs/MARKET.md`.
- Add the offer test and its threshold to the plan's discovery phase (see
  `phased-plan`). If the project already runs the forbidden-phrases guard, append the
  list to its phrases file; otherwise `project-setup` seeds the file from this one.
- The next link of the chain is `/coderachnid:product-brief`, in a fresh session (see
  `handoff`).
