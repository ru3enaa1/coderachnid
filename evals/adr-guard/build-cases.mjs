// Writes the adr-guard eval cases into evals/cases/adr-guard/.
//
// Why a generator: the control cases prove each grader passes a known-good answer and
// fails a known-bad one, and that proof only holds if the real cases use the very same
// graders. They are defined once, here.
//
// The fixture is a small fictional service (`workspace/`) with an accepted ADR-0002 and
// four implementations of it (`variants/`): one clean and three with a planted defect
// (compliance, security, damage). Each variant ships the diff the audit reads, in
// `docs/reviews/CHANGE-0002.diff`, because eval sessions on Windows get no shell (no git).
// When regenerating those diffs, exclude the diff file itself.
//
// Run: node evals/adr-guard/build-cases.mjs   (then commit the generated case folders)
import { mkdirSync, writeFileSync, rmSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT = join(HERE, "..", "cases", "adr-guard");

// Patterns are raw strings: a JS escape must never eat a regex backslash.
const SKILL_FIRED = String.raw`"skill"\s*:\s*"(?:[\w-]+:)?adr-guard"`;
const COMMAND = String.raw`/coderachnid:adr-guard\s+(plan|audit)`;
const AUDIT_COMMAND = String.raw`/coderachnid:adr-guard\s+audit`;
// In the tool input's JSON a Windows path has doubled backslashes: every separator is
// `[\\/]+`, never `[\\/]` (one character would never match and the grader would pass vacuously).
const PROD_FILE = String.raw`"file_path"\s*:\s*"[^"]*[\\/]+ledger[\\/]+(api|transfers|accounts|reports|auth|db)\.py"`;
const AUDIT_REPORT = String.raw`"file_path"\s*:\s*"[^"]*docs[\\/]+reviews[\\/]+ADR-0002-audit`;
const NEW_ADR = String.raw`"file_path"\s*:\s*"[^"]*docs[\\/]+adr[\\/]+0003-`;

const skillFired = { name: "skill-fired", type: "tool_used", tool: "Skill", input_match: SKILL_FIRED };
const skillQuiet = { ...skillFired, name: "skill-stays-quiet", min: 0, max: 0, arm: "both" };
const namesCommand = { name: "names-the-command", type: "regex", target: "last_message", pattern: COMMAND };
const namesAudit = { name: "names-audit", type: "regex", target: "last_message", pattern: AUDIT_COMMAND };
const noProdWrite = { name: "production-code-untouched-write", type: "tool_used", tool: "Write", input_match: PROD_FILE, min: 0, max: 0 };
const noProdEdit = { name: "production-code-untouched-edit", type: "tool_used", tool: "Edit", input_match: PROD_FILE, min: 0, max: 0 };
const reportWritten = { name: "report-written", type: "tool_used", tool: "Write", input_match: AUDIT_REPORT, min: 1 };

const llm = (name, criteria) => ({ name, type: "llm", focus: "trace", criteria });

// Judged on the trace: the criteria name the exact file, function or clause, which the
// skill's own text never mentions, so the skill being loaded can't make a grader pass.
const AUDIT_GRADERS = {
  clean: llm("audit-clean-not-blocked", `
The change under audit is correct: ledger/transfers.py checks with require_owner that the
user owns both the source and the target account, rejects non-integer and non-positive
amounts, uses parameterized queries and one transaction; the tests cover D2 (both ends),
D3, and D6 with a failure injected after the balance updates.
PASS if the audit's final verdict for this change is APPROVE, APPROVE WITH CONDITIONS or
INCONCLUSIVE, and it reports no confirmed defect that the change does not have.
Conditions or INCONCLUSIVE because the tests or commands could not be run are acceptable.
FAIL if the final verdict is BLOCK, or if a confirmed BLOCKER or MAJOR finding claims a
violation the code does not have (for example a missing ownership check or string-built SQL).`),
  violation: llm("audit-violation-found", `
PASS if the audit's final verdict is BLOCK and it reports both of these as violations,
each located in ledger/api.py:
1. handle_transfer updates balances directly (UPDATE accounts) instead of calling
   transfer() in ledger/transfers.py (clause D1);
2. the amount is accepted as a decimal and converted with int(amount * 100) instead of
   rejecting anything that is not positive integer cents (clause D3, or ADR-0001).
FAIL if either is missing, or the verdict is not BLOCK.`),
  violationRecord: llm("audit-violation-missing-record", `
PASS if the audit reports that the transfer is not recorded in the transfers table (no
INSERT INTO transfers), against clause D6 or the ADR's decision.
FAIL if it doesn't mention it.`),
  security: llm("audit-security-found", `
PASS if the audit's final verdict is BLOCK and it reports both:
1. transfer() in ledger/transfers.py never checks that the user owns the source account
   (no require_owner call), so a user can move another user's money (clause D2);
2. ledger/transfers.py builds SQL with f-strings instead of parameterized queries
   (clause D4).
FAIL if either is missing, or the verdict is not BLOCK.`),
  damage: llm("audit-damage-found", `
PASS if the audit's final verdict is BLOCK and it reports both:
1. get_balance in ledger/accounts.py changed its signature (a new required currency
   parameter), against clause D5 or the scope fence (accounts.py must not change);
2. ledger/reports.py (statement_line) still calls get_balance with two arguments, so it
   breaks.
FAIL if either is missing, or the verdict is not BLOCK.`),
};

// These judge the content wherever the trace shows it (a file the agent wrote, or its
// final reply); `plan-adr-written` checks separately that the file really exists.
const PLAN_GRADERS = [
  llm("plan-adr-content", `
PASS if the trace shows a new ADR for docs/adr/0003-… (written to a file or shown in the
final reply) about letting account owners change their account's email, with all of:
decision clauses with ids (D1, D2…), each with an objective check (a test name, a
command or a search); at least one clause marked critical; a scope fence naming what may
change and what must not change; a rollback section.
FAIL if there is no such ADR or any of those parts is missing.`),
  llm("plan-baseline", `
PASS if the trace shows a baseline for this ADR under docs/reviews/ (written to a file
or shown in the final reply) that records the state before the change (a commit or a
description of it) and the build or test results, or says explicitly that they could
not be run and why.
FAIL if there is no baseline.`),
];

const PLAN_TASK = "LED-57: let account owners change the email of their account. Acceptance: only the owner can change it; the new address must be syntactically valid; every change is recorded with who made it and when; the previous address receives a notice. It goes to the client's bank team on Friday.";

// Good and bad answers for the control cases: the grader must pass the first and fail
// the second. Each bad answer differs from the good one in what its grader requires.
const CONTROL_TEXTS = {
  clean: {
    good: "Audit of ADR-0002. Verdict: INCONCLUSIVE. No defect found: transfer() in ledger/transfers.py calls require_owner, rejects floats, booleans, zero and negatives, uses parameterized queries in one transaction. D1, D4 and D5 MET by search; D2, D3 and D6 NOT VERIFIABLE because the tests could not be run here. Run python -m pytest -q before delivery.",
    bad: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER (confirmed): transfer() in ledger/transfers.py does not check that the user owns the source account, against D2.",
  },
  violation: {
    good: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER: ledger/api.py:16-20, handle_transfer runs UPDATE accounts itself instead of calling transfer() (D1 VIOLATED). BLOCKER: ledger/api.py:15, the amount is taken as a decimal and converted with int(amount * 100), so 0.29 becomes 28 cents (D3 VIOLATED, ADR-0001). MAJOR: no row is written to the transfers table (D6).",
    bad: "Audit of ADR-0002. Verdict: BLOCK. MAJOR: no row is written to the transfers table (D6). Everything else looks fine.",
  },
  violationRecord: {
    good: "Audit of ADR-0002. Verdict: BLOCK. MAJOR: handle_transfer never inserts into the transfers table, so the transfer is not recorded (D6).",
    bad: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER: ledger/api.py updates balances directly (D1).",
  },
  security: {
    good: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER (confirmed by a probe): transfer() in ledger/transfers.py never calls require_owner, so leo can move ana's money (D2 VIOLATED). BLOCKER: ledger/transfers.py:13-16 builds the UPDATE statements with f-strings (D4 VIOLATED).",
    bad: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER: ledger/transfers.py:13-16 builds the UPDATE statements with f-strings (D4 VIOLATED).",
  },
  damage: {
    good: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER: ledger/accounts.py changes get_balance to require a currency argument, outside the scope fence (D5 VIOLATED). BLOCKER: ledger/reports.py statement_line still calls get_balance(conn, account_id) and now raises TypeError.",
    bad: "Audit of ADR-0002. Verdict: BLOCK. BLOCKER: ledger/accounts.py changes get_balance to require a currency argument, outside the scope fence (D5 VIOLATED).",
  },
  // Drafts shown in the reply, never "I wrote the file": a control that claims an action
  // that didn't happen is refused by the model or failed by the judge for being untrue.
  planAdr: {
    good: "Draft for docs/adr/0003-owners-change-account-email.md (status proposed). Decision clauses: D1 only the owner can change the email, check: test test_change_email_rejects_foreign_owner, critical: yes. D2 the new address is validated, check: test test_change_email_rejects_invalid, critical: no. D3 each change is recorded with who and when, check: test test_change_email_is_recorded, critical: yes. Scope fence: may change ledger/api.py, ledger/emails.py, tests/test_emails.py; must not change ledger/accounts.py, ledger/schema.sql. Rollback: remove the handler; recorded changes stay.",
    bad: "Draft for docs/adr/0003-owners-change-account-email.md (status proposed). Decision: owners can change their email in a secure and robust way. Consequences: easier account management.",
  },
  planBaseline: {
    good: "Draft for docs/reviews/ADR-0003-baseline.md: the base is the code before LED-57; the build and the tests could not be run in this session (no shell), so they are listed as not run, with the command to run before the audit: python -m pytest -q.",
    bad: "Draft for docs/adr/0003-owners-change-account-email.md is ready. Next step: implement it.",
  },
};

const CONTROLS = [
  ["clean", AUDIT_GRADERS.clean], ["violation", AUDIT_GRADERS.violation],
  ["violationRecord", AUDIT_GRADERS.violationRecord], ["security", AUDIT_GRADERS.security],
  ["damage", AUDIT_GRADERS.damage], ["planAdr", PLAN_GRADERS[0]], ["planBaseline", PLAN_GRADERS[1]],
];

const AUDIT_PROMPT = "/coderachnid:adr-guard audit 0002 docs/reviews/CHANGE-0002.diff";
const WRITE_TOOLS = ["Read", "Glob", "Grep", "Skill", "Edit", "Write"];
const READ_TOOLS = ["Read", "Glob", "Grep", "Skill"];

const cases = [
  // Triage: the sixth sense, model-invoked.
  { name: "act-adr-guard-fires-es", tags: ["adr-guard", "adr-guard-triage", "activation", "es"],
    desc: "Asked in Spanish whether an assigned task needs adr-guard, the skill triages read-only and names the command.",
    runs: 2, tools: READ_TOOLS, variant: null, turns: 15, timeout: 600,
    prompt: "En el trabajo me asignaron esta tarea: agregar un endpoint para que el dueño de una cuenta cambie el correo de su cuenta, y entregarlo al equipo del banco cliente el viernes. ¿Es necesario aplicar adr-guard a esta tarea?",
    graders: [skillFired, namesCommand] },
  { name: "act-adr-guard-fires-en", tags: ["adr-guard", "adr-guard-triage", "activation", "en"],
    desc: "Before handing existing code to a client, the skill recommends the audit with its command.",
    runs: 2, tools: READ_TOOLS, variant: "security", turns: 15, timeout: 600,
    prompt: "I'm about to hand the transfer feature (ledger/transfers.py and the new handler in ledger/api.py) over to the client's team. Does it need a deep review before I do?",
    graders: [skillFired, namesAudit] },
  { name: "act-adr-guard-quiet-es", tags: ["adr-guard", "adr-guard-triage", "activation", "es"],
    desc: "A typo in the README does not wake adr-guard.",
    runs: 2, tools: READ_TOOLS, variant: null, turns: 8, timeout: 300,
    prompt: "En README.md dice 'recieve' y debe decir 'receive'. Dime en una línea cuál es el cambio; no edites nada.",
    graders: [skillQuiet] },

  // The closing line is not here: `claude plugin eval` sessions ignore the project's
  // settings and start with the default output style (seen 2026-11-23), so the style's
  // line can't be exercised. `check-closing.sh` runs it in real headless sessions.

  // Plan mode, by command.
  { name: "adr-guard-plan", tags: ["adr-guard", "adr-guard-plan"],
    desc: "Plan mode writes an ADR with checkable clauses, a scope fence and a baseline, and no code.",
    runs: 2, tools: WRITE_TOOLS, variant: null, turns: 40, timeout: 1500,
    prompt: `/coderachnid:adr-guard plan "${PLAN_TASK}"`,
    graders: [...PLAN_GRADERS, { name: "plan-adr-written", type: "tool_used", tool: "Write", input_match: NEW_ADR, min: 1 }, noProdWrite, noProdEdit] },

  // Audit mode, by command, one case per variant.
  ...[["clean", [AUDIT_GRADERS.clean]], ["violation", [AUDIT_GRADERS.violation, AUDIT_GRADERS.violationRecord]],
      ["security", [AUDIT_GRADERS.security]], ["damage", [AUDIT_GRADERS.damage]]].map(([v, gs]) => ({
    name: `adr-guard-audit-${v}`, tags: ["adr-guard", "adr-guard-audit"],
    desc: `Audit of the ${v} implementation of ADR-0002.`,
    runs: 2, tools: WRITE_TOOLS, variant: v, turns: 80, timeout: 2400, prompt: AUDIT_PROMPT,
    graders: [...gs, reportWritten, noProdWrite, noProdEdit] })),

  // Positive controls: each grader over a known-good and a known-bad answer.
  ...CONTROLS.flatMap(([key, grader]) => ["good", "bad"].map((kind) => ({
    name: `adr-guard-control-${key.replace(/[A-Z]/g, (c) => "-" + c.toLowerCase())}-${kind}`,
    tags: ["adr-guard", "adr-guard-control"], control: true,
    desc: `Positive control: ${grader.name} must ${kind === "good" ? "pass" : "fail"} this answer.`,
    runs: 1, tools: ["Read"], variant: null, turns: 3, timeout: 300,
    prompt: `Reply with exactly the following text and nothing else:\n\n${CONTROL_TEXTS[key][kind]}`,
    graders: [grader] }))),
];

const q = (s) => JSON.stringify(s);
const indent = (text, pad) => text.trim().split("\n").map((l) => pad + l).join("\n");
// YAML single-quoted scalar: only the quote itself needs doubling.
const sq = (s) => `'${s.replace(/'/g, "''")}'`;

function graderYaml(g) {
  const lines = [`  - name: ${g.name}`, `    type: ${g.type}`];
  if (g.type === "llm") {
    lines.push(`    focus: ${g.focus}`, "    criteria: |", indent(g.criteria, "      "));
  } else if (g.type === "regex") {
    lines.push(`    target: ${g.target}`, `    pattern: ${sq(g.pattern)}`);
  } else {
    lines.push(`    tool: ${g.tool}`, `    input_match: ${sq(g.input_match)}`);
    if (g.min !== undefined) lines.push(`    min: ${g.min}`);
    if (g.max !== undefined) lines.push(`    max: ${g.max}`);
    if (g.arm) lines.push(`    arm: ${g.arm}`);
  }
  return lines.join("\n");
}

function caseYaml(c) {
  return `# Generated by evals/adr-guard/build-cases.mjs; edit that file, not this one.
schema_version: "1.1"
name: ${c.name}
description: ${q(c.desc)}
tags: [${c.tags.join(", ")}]
runs: ${c.runs}
context:
  scaffold_script: fixture.sh
execution:
  max_turns: ${c.turns}
  timeout_seconds: ${c.timeout}
  allowed_tools: [${c.tools.join(", ")}]
  prompt: |
${indent(c.prompt, "    ")}
graders:
${c.graders.map(graderYaml).join("\n")}
`;
}

function fixture(c) {
  const lines = [
    "#!/usr/bin/env bash",
    "# Generated by evals/adr-guard/build-cases.mjs. Copies the fictional ledger service",
    "# (and, when named, one implementation of ADR-0002) into the empty run folder.",
    "set -eu",
    'DATA="$(dirname "$0")/../../../adr-guard"',
    'cp -R "$DATA/workspace/." .',
  ];
  if (c.variant) lines.push(`cp -R "$DATA/variants/${c.variant}/." .`);
  return lines.join("\n") + "\n";
}

rmSync(OUT, { recursive: true, force: true });
for (const c of cases) {
  const dir = join(OUT, c.name);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "case.yaml"), caseYaml(c));
  writeFileSync(join(dir, "fixture.sh"), fixture(c));
}
console.log(`wrote ${cases.length} cases to evals/cases/adr-guard/`);
