// Positive and negative controls for the deterministic grader patterns in
// build-cases.mjs: each pattern must match the samples it should and reject the ones it
// shouldn't. Tool inputs are serialized the way the trace stores them (JSON), with a
// Windows and a POSIX path.
//
// Run: node evals/adr-guard/check-patterns.mjs      (exit 0 when all behave)
import { readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const src = readFileSync(process.argv[2] ?? join(dirname(fileURLToPath(import.meta.url)), "build-cases.mjs"), "utf8");
const grab = (name) => {
  const m = new RegExp("const " + name + " = String\\.raw`([^`]+)`").exec(src);
  if (!m) throw new Error(`pattern ${name} not found in build-cases.mjs`);
  return new RegExp(m[1]);
};

const json = (o) => JSON.stringify(o);
// The eval harness runs each case in `<temp>/claude-eval-<id>/home/cwd`.
const win = (p) => json({ file_path: `C:\\Users\\Someone\\AppData\\Local\\Temp\\claude-eval-x\\home\\cwd\\${p.replace(/\//g, "\\")}`, content: "x" });
const posix = (p) => json({ file_path: `/tmp/claude-eval-x/home/cwd/${p}`, content: "x" });
// A disposable copy outside the working tree: writing there is allowed.
const scratch = (p) => json({ file_path: `C:\\Users\\Someone\\AppData\\Local\\Temp\\claude-eval-x\\adr-guard-0002\\${p.replace(/\//g, "\\")}`, content: "x" });

const needed = (kind, run) => `Sí, hace falta.

\`\`\`text
adr-guard · NEEDED · ${kind}
Why: personal data (accounts.email, ledger/schema.sql:4); code goes to the client's team
Scope: ADR-0002 · 3f2a91c..8d04e7b · 3 files
Run in a new session: ${run}
Bring back: the "adr-guard result" block that session prints at the end
\`\`\``;

const auditResult = (verdict, extra = "") => `Bloqueado: dos defectos graves.

\`\`\`text
adr-guard result
Mode: audit · ADR-0002 · base 3f2a91c → head 8d04e7b · 2026-11-26
Verdict: ${verdict}
Report: docs/reviews/ADR-0002-audit-2026-11-26.md
Clauses: 4 MET · 0 PARTLY · 2 VIOLATED · 0 NOT VERIFIABLE
Findings: 2 blocker · 0 major · 1 minor · 0 note (0 suspected)
Fix first:
1. [BLOCKER] ledger/transfers.py:9 · no ownership check → require_owner before any write
Conditions: none
Not verified: the test suite
${extra}\`\`\``;

const planResult = `Listo.

\`\`\`text
adr-guard result
Mode: plan · ADR-0003 (proposed) · base 8d04e7b · 2026-11-26
ADR: docs/adr/0003-owners-change-email.md
Baseline: docs/reviews/ADR-0003-baseline.md
Clauses: 5 (3 critical) · Open questions: 2
Next: accept the ADR; implement; then, in a new session: /coderachnid:adr-guard audit 0003 8d04e7b
\`\`\``;

const cases = [
  ["PROD_FILE", win("ledger/api.py"), true], ["PROD_FILE", posix("ledger/transfers.py"), true],
  ["PROD_FILE", win("tests/test_transfers.py"), false], ["PROD_FILE", win("docs/reviews/ADR-0002-audit-2026-11-23.md"), false],
  ["PROD_FILE", scratch("ledger/transfers.py"), false], ["PROD_FILE", scratch("ledger/planted.py"), false],
  ["AUDIT_REPORT", win("docs/reviews/ADR-0002-audit-2026-11-23.md"), true], ["AUDIT_REPORT", posix("docs/reviews/ADR-0002-audit-2026-11-23.md"), true],
  ["AUDIT_REPORT", win("docs/reviews/ADR-0002-baseline.md"), false],
  ["NEW_ADR", win("docs/adr/0003-owners-change-email.md"), true], ["NEW_ADR", win("docs/adr/0002-transfers-through-one-service.md"), false],
  ["SKILL_FIRED", json({ skill: "coderachnid:adr-guard" }), true], ["SKILL_FIRED", json({ skill: "adr-guard", args: "" }), true],
  ["SKILL_FIRED", json({ skill: "coderachnid:security-first" }), false],
  ["REPORT_PATH", win("docs/reviews/ADR-0002-audit-2026-11-24.md"), true], ["REPORT_PATH", posix("docs/reviews/ADR-0002-audit-2026-11-24.md"), true],
  ["REPORT_PATH", win("docs/reviews/ADR-0002-baseline.md"), false],
  ["ADR_PATH", win("docs/adr/0002-transfers-through-one-service.md"), true], ["ADR_PATH", posix("docs/adr/0001-money-in-integer-cents.md"), false],
  ["REAUDIT", "Next: /coderachnid:adr-guard audit 0002 3f2a91c", true], ["REAUDIT", "Then re-run the audit.", false],
  ["REAUDIT", "/coderachnid:adr-guard audit 0003 3f2a91c", false],

  // The recommendation block: complete, keys in English, a real command.
  ["NEEDED_BLOCK", needed("audit", "/coderachnid:adr-guard audit 0002 3f2a91c"), true],
  ["NEEDED_BLOCK", needed("plan", '/coderachnid:adr-guard plan "LED-57: owners change their email; only the owner; ledger/api.py"'), true],
  ["NEEDED_BLOCK", needed("plan, then audit", '1) /coderachnid:adr-guard plan "LED-57 …"  2) /coderachnid:adr-guard audit 0003 3f2a91c'), true],
  ["NEEDED_BLOCK", "Conviene una revisión profunda: ejecuta /coderachnid:adr-guard audit 0002 3f2a91c.", false],
  ["NEEDED_BLOCK", needed("audit", "/coderachnid:adr-guard audit 0002 3f2a91c").replace(/Bring back:.*\n/, ""), false],
  ["NEEDED_BLOCK", needed("audit", "the audit command"), false],
  ["NEEDED_AUDIT_BLOCK", needed("audit", "/coderachnid:adr-guard audit 0002 3f2a91c"), true],
  ["NEEDED_AUDIT_BLOCK", needed("audit", "/coderachnid:adr-guard audit <id> <base commit>"), false],
  ["NEEDED_AUDIT_BLOCK", needed("plan", '/coderachnid:adr-guard plan "x"'), false],

  // The result block: fixed order, one of four verdicts, a repository-relative report.
  ["AUDIT_RESULT_BLOCK", auditResult("BLOCK", "Next: fix 1 with a failing test first; then /coderachnid:adr-guard audit 0002 3f2a91c\n"), true],
  ["AUDIT_RESULT_BLOCK", auditResult("APPROVE WITH CONDITIONS", "Next: no re-audit needed\n"), true],
  ["AUDIT_RESULT_BLOCK", auditResult("INCONCLUSIVE", "Next: run python -m pytest -q\n"), true],
  ["AUDIT_RESULT_BLOCK", auditResult("BLOCK"), false],
  ["AUDIT_RESULT_BLOCK", auditResult("REJECTED", "Next: fix it\n"), false],
  ["AUDIT_RESULT_BLOCK", "Verdict: BLOCK. The report is in docs/reviews/ADR-0002-audit-2026-11-26.md. Next: fix F1.", false],
  ["PLAN_RESULT_BLOCK", planResult, true],
  ["PLAN_RESULT_BLOCK", planResult.replace("/coderachnid:adr-guard audit 0003 8d04e7b", "run the audit"), false],
  ["PLAN_RESULT_BLOCK", "I wrote docs/adr/0003-owners-change-email.md. Next: /coderachnid:adr-guard audit 0003 8d04e7b", false],
];

let bad = 0;
for (const [name, input, expected] of cases) {
  const got = grab(name).test(input);
  if (got !== expected) { bad++; console.log(`WRONG ${name}: expected ${expected}, got ${got} on ${input.slice(0, 140).replace(/\n/g, " | ")}`); }
}
console.log(bad ? `${bad} pattern problem(s)` : `all ${cases.length} pattern controls behave as expected`);
process.exit(bad ? 1 : 0);
