// Writes the discovery-chain eval cases into evals/cases/chain/.
//
// Why a generator: a grader is trusted only after it passes a known-good file and fails a
// known-bad one (positive control). That proof holds only if the control cases and the
// real cases use the very same graders, so they are defined once, here.
//
// Run: node evals/chain/build-cases.mjs   (then commit the generated case folders)
import { mkdirSync, writeFileSync, rmSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT = join(HERE, "..", "cases", "chain");

const llm = (name, path, criteria) => ({ name, path, criteria });

const OFFER = "docs/OFFER.md";
const BRIEF = "docs/BRIEF.md";
const PRD = "docs/PRD.md";

const offerGraders = [
  llm("offer-value-proposition", OFFER, `
PASS if the document has a value proposition in one sentence that names all four of:
a specific customer, a specific problem, an outcome, and an alternative it is compared
against (a named competitor or a substitute such as manual calls).
FAIL if any of the four is missing, or if it is generic praise ("the best platform").`),
  llm("offer-tiers-anchored", OFFER, `
PASS if all of these hold:
1. There are exactly three price tiers, each with a concrete price (a number).
2. Each tier's price is compared to a named competitor's price or to a measured current
   spend, with a reference to where that figure comes from.
3. The prices are labelled as assumptions, hypotheses or untested.
FAIL if any of the three is missing.`),
  llm("offer-guarantee-honest", OFFER, `
PASS if all of these hold:
1. There is a guarantee that states what triggers it and what the customer gets.
2. It names the consumer rules of the regions or says they must be confirmed by a lawyer.
3. It does not guarantee an outcome the product cannot control (for example 100%
   attendance, guaranteed bookings, guaranteed revenue).
FAIL if any of the three is missing or broken.`),
  llm("offer-test-threshold", OFFER, `
PASS if the document proposes a concrete, cheap test of the offer (for example a landing
page with a deposit, a waitlist or interviews with a price question) with a numeric
success threshold and a date or time limit.
FAIL if there is no test, or the test has no numeric threshold.`),
  llm("offer-never-promise", OFFER, `
PASS if the document contains an explicit list of phrases or promises the product must
never make, and the list includes at least one outcome guarantee or one kind of invented
social proof.
FAIL if there is no such list.`),
];

const briefGraders = [
  llm("brief-competitor-look", BRIEF, `
PASS if the document describes how the competitors look (colors, imagery or layout),
names the look most of them share, and chooses a design direction that differs from it.
FAIL if competitors' look is not discussed, or the chosen direction copies it.`),
  llm("brief-palette-one-accent", BRIEF, `
PASS if the palette is given as hex color values made of neutrals plus exactly one
accent color.
FAIL if there are no hex values, or if two or more accent colors are proposed.`),
  llm("brief-mockup-prompt", BRIEF, `
PASS if the document contains a self-contained mockup prompt (a fenced block or a
clearly delimited section meant to be copied) that describes the layout, typography,
colors with hex values, the hero visual and the primary call to action, and mentions
both desktop and mobile.
FAIL if any of these is missing.`),
  llm("brief-social-proof-placeholder", BRIEF, `
PASS if the document says explicitly that social proof (testimonials, user or customer
counts, client logos) is a placeholder or must not be shown until it is real, AND it
presents no invented social proof as real.
FAIL if it presents invented social proof as fact (for example "Trusted by 10,000+
clinics" or a made-up testimonial) or never addresses social proof.`),
];

// The requirements moved to their own file in v0.8.0; the last three graders are the
// ones that judged them inside the brief before.
const prdGraders = [
  llm("prd-what-who-where", PRD, `
PASS if the document states all three:
1. What is being built, in concrete terms (what the user does with it).
2. Who it is for: one specific kind of customer or user.
3. The context of use: the situation or moment in which it is used, and the device or
   platform.
FAIL if any of the three is missing. A description made only of praise words such as
"powerful", "modern" or "intuitive" does not count for point 1, and "for everyone" or
"all sizes" does not count for point 2.`),
  llm("prd-features-traced", PRD, `
PASS if the core features are listed with an identifier each, and every feature has a
priority (for example Must / Should / Later) AND the problem it serves.
FAIL if features are a bare list of names, or lack priorities, or do not say which
problem each one serves.`),
  llm("prd-how-it-works", PRD, `
PASS if the document describes at least one main user journey as ordered steps that say
what the user does and what the system does or shows, AND describes what happens when a
step fails (for example invalid input or a service that is down).
FAIL if there is no step-by-step journey, or no failure case is described.`),
  llm("prd-metrics-nongoals", PRD, `
PASS if the document gives at least one success metric with a numeric target and says how
or when it is measured, AND lists non-goals or things explicitly out of scope.
FAIL if there is no metric with a number, or nothing is declared out of scope.`),
  llm("prd-stories-criteria", PRD, `
PASS if there are user stories and each has testable acceptance criteria (for example
Given / When / Then), and at least one criterion covers a failure or error path.
FAIL if there are no stories, the stories have no acceptance criteria, or no failure
path is covered.`),
  llm("prd-data-threats", PRD, `
PASS if the document lists the personal data the product handles, with why each is
needed and where it is stored or how long it is kept, and names at least two threats,
each with a control.
FAIL if personal data or threats with controls are missing.`),
  llm("prd-entities-scope", PRD, `
PASS if the document lists the main data entities with their key fields, AND defines the
MVP scope with an explicit list of what is NOT in it.
FAIL if either is missing.`),
];

const briefAndPrd = [...prdGraders, ...briefGraders];

const CONTROL_PROMPT = "Reply with the single word OK. Do not read, create or change any file.";

const cases = [
  { name: "chain-offer-command", desc: "The offer skill, run by its command, writes a complete offer.",
    tags: ["chain", "chain-run", "offer"], runs: 2, prompt: '/coderachnid:offer "RecallKit"',
    graders: offerGraders, extra: [] },
  { name: "chain-offer-loose", desc: "Baseline: the same offer asked for in a loose prompt, without the command.",
    tags: ["chain", "chain-run", "offer"], runs: 2,
    prompt: "Con lo que hay en docs/MARKET.md, arma la oferta comercial de RecallKit y guárdala en docs/OFFER.md.",
    graders: offerGraders, extra: [] },
  { name: "chain-brief-command", desc: "The product-brief skill, run by its command, writes a complete PRD and design brief.",
    tags: ["chain", "chain-run", "product-brief"], runs: 2, prompt: '/coderachnid:product-brief "RecallKit"',
    graders: briefAndPrd, extra: [["offer-good.md", OFFER]] },
  { name: "chain-brief-loose", desc: "Baseline: the same two documents asked for in a loose prompt, without the command.",
    tags: ["chain", "chain-run", "product-brief"], runs: 2,
    prompt: "Con docs/MARKET.md, docs/OFFER.md y docs/brand.md, escribe los requisitos del producto RecallKit (el PRD) en docs/PRD.md y el brief de diseño en docs/BRIEF.md.",
    graders: briefAndPrd, extra: [["offer-good.md", OFFER]] },
  { name: "chain-control-offer-good", desc: "Positive control: every offer grader passes a known-good offer.",
    tags: ["chain", "chain-control"], runs: 1, prompt: CONTROL_PROMPT, control: true,
    graders: offerGraders, extra: [["offer-good.md", OFFER]] },
  { name: "chain-control-offer-bad", desc: "Positive control: every offer grader fails a known-bad offer (expected score 0).",
    tags: ["chain", "chain-control"], runs: 1, prompt: CONTROL_PROMPT, control: true,
    graders: offerGraders, extra: [["offer-bad.md", OFFER]] },
  { name: "chain-control-brief-good", desc: "Positive control: every PRD and brief grader passes known-good documents.",
    tags: ["chain", "chain-control"], runs: 1, prompt: CONTROL_PROMPT, control: true,
    graders: briefAndPrd, extra: [["offer-good.md", OFFER], ["prd-good.md", PRD], ["brief-good.md", BRIEF]] },
  { name: "chain-control-brief-bad", desc: "Positive control: every PRD and brief grader fails known-bad documents (expected score 0).",
    tags: ["chain", "chain-control"], runs: 1, prompt: CONTROL_PROMPT, control: true,
    graders: briefAndPrd, extra: [["offer-good.md", OFFER], ["prd-bad.md", PRD], ["brief-bad.md", BRIEF]] },
];

const q = (s) => JSON.stringify(s);
const indent = (text, pad) => text.trim().split("\n").map((l) => pad + l).join("\n");

function caseYaml(c) {
  const tools = c.control ? "[Read]" : "[Read, Glob, Grep, Skill, Edit, Write]";
  const graders = c.graders.map((g) => `  - name: ${g.name}
    type: llm
    focus: { source: file, path: ${g.path} }
    criteria: |
${indent(g.criteria, "      ")}`).join("\n");
  return `# Generated by evals/chain/build-cases.mjs; edit that file, not this one.
schema_version: "1.1"
name: ${c.name}
description: ${q(c.desc)}
tags: [${c.tags.join(", ")}]
runs: ${c.runs}
context:
  scaffold_script: fixture.sh
execution:
  max_turns: ${c.control ? 3 : 40}
  timeout_seconds: ${c.control ? 300 : 1200}
  allowed_tools: ${tools}
  prompt: |
${indent(c.prompt, "    ")}
graders:
${graders}
`;
}

function fixture(c) {
  const copies = c.extra.map(([from, to]) => `cp "$DATA/controls/${from}" "${to}"`).join("\n");
  return `#!/usr/bin/env bash
# Generated by evals/chain/build-cases.mjs. Copies the fictional RecallKit workspace${c.extra.length ? " and\n# the documents this case starts from" : ""} into the empty run folder.
set -eu
DATA="$(dirname "$0")/../../../chain"
cp -R "$DATA/workspace/." .
${copies}
`.replace(/\n\n$/, "\n");
}

rmSync(OUT, { recursive: true, force: true });
for (const c of cases) {
  const dir = join(OUT, c.name);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "case.yaml"), caseYaml(c));
  writeFileSync(join(dir, "fixture.sh"), fixture(c));
}
console.log(`wrote ${cases.length} cases to evals/cases/chain/`);
