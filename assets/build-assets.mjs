// Generates the README artwork: the sticker logo and the banner, each in a dark and a
// light variant. The drawing is deterministic (fixed filter seeds, no randomness), so
// running it twice produces identical files.
//
// Usage: node assets/build-assets.mjs
// Output: assets/logo-dark.svg, assets/logo-light.svg,
//         assets/banner-dark.svg, assets/banner-light.svg
//
// Why SVG and not PNG: it stays sharp at any size and weighs a few kilobytes.
// Why system fonts: an SVG shown through <img> on GitHub cannot load web fonts,
// so text uses a monospace stack every platform has.

import { existsSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const OUT = dirname(fileURLToPath(import.meta.url));
// The banner states the skill count; read it from disk so it never drifts.
// guards/check-skills.sh fails if the banner or the README badge disagree with it.
const SKILLS_DIR = join(OUT, "..", "skills");
const SKILL_COUNT = readdirSync(SKILLS_DIR, { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(join(SKILLS_DIR, d.name, "SKILL.md"))).length;
const MONO = "ui-monospace, 'SF Mono', 'Cascadia Mono', Consolas, 'DejaVu Sans Mono', monospace";
const INK = "#141414";
const PAPER = "#fbfaf6";

const THEMES = {
  dark: { bg: "#0b0f14", code: "#c9d1d9", web: "#e8e4dc", amber: "#ffb547", text: "#efe9df", muted: "#8b929c", line: "#1f2630", outline: "#0b0f14" },
  light: { bg: "#f6f3ec", code: "#3b4049", web: "#24292f", amber: "#c27400", text: "#1d2127", muted: "#5b626c", line: "#ddd6c8", outline: "#1d2127" },
};

const f = (n) => n.toFixed(1);
const poly = (pts) => pts.map(([x, y]) => `${f(x)},${f(y)}`).join(" ");
const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

// ---- Sticker logo -------------------------------------------------------------------

// Left legs as knee-bent polylines; the right side mirrors them around x = 120.
const LEGS = [
  [[108, 62], [78, 30], [58, 14]],
  [[104, 70], [62, 56], [34, 66]],
  [[104, 82], [60, 96], [38, 126]],
  [[108, 92], [78, 128], [66, 164]],
];
const ALL_LEGS = LEGS.concat(LEGS.map((leg) => leg.map(([x, y]) => [240 - x, y])));
const LOGO_VIEWBOX = [16, -2, 208, 186];

// Two filters. "k" cuts the sticker: grow the drawing's outline a little, close tiny
// gaps, wobble the edge so it looks cut by hand, paint it paper-white, and lay a thin
// outline under it (visible only on light backgrounds). "i" wobbles the ink lines.
function stickerDefs(uid, seed, outline) {
  return `<defs>
<filter id="k${uid}" x="-25%" y="-25%" width="150%" height="150%">
<feMorphology in="SourceAlpha" operator="dilate" radius="5" result="a"/>
<feMorphology in="a" operator="erode" radius="1" result="b"/>
<feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves="2" seed="${seed}" result="t"/>
<feDisplacementMap in="b" in2="t" scale="4.5" xChannelSelector="R" yChannelSelector="G" result="cut"/>
<feMorphology in="cut" operator="dilate" radius="1.2" result="cutO"/>
<feFlood flood-color="${outline}"/><feComposite in2="cutO" operator="in" result="ol"/>
<feFlood flood-color="${PAPER}"/><feComposite in2="cut" operator="in" result="pp"/>
<feMerge><feMergeNode in="ol"/><feMergeNode in="pp"/><feMergeNode in="SourceGraphic"/></feMerge>
</filter>
<filter id="i${uid}" x="-10%" y="-10%" width="120%" height="120%">
<feTurbulence type="fractalNoise" baseFrequency="0.07" numOctaves="2" seed="${seed + 1}" result="t"/>
<feDisplacementMap in="SourceGraphic" in2="t" scale="3.2" xChannelSelector="R" yChannelSelector="G"/>
</filter>
</defs>`;
}

// The spider: solid ink body, no face, amber < > on the abdomen. Each leg gets a thin
// second stroke slightly offset, like a sketch that was gone over twice.
function spider(uid, outline, amber) {
  const main = ALL_LEGS.map((leg) => `<polyline points="${poly(leg)}"/>`).join("");
  const sketch = ALL_LEGS.map((leg, i) => {
    const side = i < 4 ? -1 : 1;
    return `<polyline points="${poly(leg.map(([x, y], j) => [x + (j ? 2.6 * side : 0), y + (j ? 2.2 : 0)]))}"/>`;
  }).join("");
  return `${stickerDefs(uid, 4, outline)}
<g filter="url(#k${uid})"><g filter="url(#i${uid})">
<g fill="none" stroke="${INK}" stroke-linecap="round" stroke-linejoin="round"><g stroke-width="8">${main}</g><g stroke-width="2">${sketch}</g></g>
<ellipse cx="120" cy="114" rx="31" ry="38" fill="${INK}"/>
<circle cx="120" cy="66" r="19" fill="${INK}"/>
<g fill="none" stroke="${amber}" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="114,103 104,115 114,127"/><polyline points="126,103 136,115 126,127"/></g>
</g></g>`;
}

function logo(theme) {
  const t = THEMES[theme];
  const [x, y, w, h] = LOGO_VIEWBOX;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${x} ${y} ${w} ${h}" width="${w}" height="${h}" role="img" aria-labelledby="t">
<title id="t">coderachnid: a hand-drawn spider sticker with an amber code bracket on its back</title>
${spider("L", t.outline, THEMES.dark.amber)}
</svg>
`;
}

// ---- Banner -------------------------------------------------------------------------

// Background code: the plugin's own subject matter, faint behind the web.
const CODE = [
  'const user = await db.get("SELECT * FROM users WHERE id = ?", [id]);',
  "if (!session || session.expiresAt < now()) return deny(401);",
  'test("rejects an expired token", () => expect(auth(expired)).toBe(false));',
  'backup("app.db") && migrate("004_add_index.sql") && verify(rowCount);',
  "// why: the cache key includes the tenant, or users see each other's data",
  'assert(res.headers["content-security-policy"] !== undefined);',
  'const rows = db.prepare("UPDATE orders SET status = ? WHERE id = ?");',
  "expect(await restore(latestBackup())).toEqual(snapshot);",
  "for (const id of createdIds) await cleanup(id); // never DELETE by pattern",
  'const secret = process.env.API_KEY ?? fail("API_KEY is not set");',
  'it("fails when the guard sees a planted error", () => { ... });',
  "escapeHtml(comment.body) // user text never reaches the DOM raw",
  "git diff --cached | guard check-private-terms || exit 1",
  "phase F1: frozen scope · branch feat/f1 · ADR-004 accepted",
  "const port = await findFreePort(); // never kill a process by name",
  'golden("invoice.pdf.txt").matches(render(invoice));',
  'rateLimit({ window: "1m", max: 30 }).on("/login");',
  "CREATE INDEX idx_orders_user ON orders(user_id); -- tested on a copy",
  "response.closing = [next, keys, watch, tests, step];",
  'if (input.length > MAX) throw new RangeError("input too long");',
];

function banner(theme) {
  const t = THEMES[theme];
  const W = 1200, H = 500, cx = 300, cy = 250, R = 225, N = 12;
  const rings = [38, 70, 106, 148, 192];
  const at = (i, r) => {
    const a = ((-90 + (i * 360) / N) * Math.PI) / 180;
    return [cx + r * Math.cos(a), cy + r * Math.sin(a)];
  };
  // One ring segment between two spokes, sagging slightly toward the center like silk.
  const seg = (i, r) => {
    const a = at(i, r), b = at(i + 1, r);
    const m = [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
    const c = [cx + (m[0] - cx) * 0.9, cy + (m[1] - cy) * 0.9];
    return `M${f(a[0])} ${f(a[1])} Q${f(c[0])} ${f(c[1])} ${f(b[0])} ${f(b[1])}`;
  };

  let code = "";
  for (let k = 0; k < 28; k++) {
    const line = `${CODE[k % CODE.length]}  ${CODE[(k * 7 + 3) % CODE.length]}`;
    code += `<text x="${24 - ((k * 37) % 120)}" y="${26 + k * 17}">${esc(line)}</text>`;
  }
  let spokes = "", web = "";
  for (let i = 0; i < N; i++) {
    const e = at(i, R);
    spokes += `<line x1="${cx}" y1="${cy}" x2="${f(e[0])}" y2="${f(e[1])}"/>`;
  }
  for (const r of rings) for (let i = 0; i < N; i++) web += `<path d="${seg(i, r)}"/>`;

  // The one thread that vibrates: where the flaw is.
  const HI = 1, HR = 148;
  const a = at(HI, HR), b = at(HI + 1, HR);
  const mid = [((a[0] + b[0]) / 2) * 0.95 + cx * 0.05, ((a[1] + b[1]) / 2) * 0.95 + cy * 0.05];

  const [lx, ly, lw, lh] = LOGO_VIEWBOX;
  const sw = 150, sh = (sw * lh) / lw;
  const label = (y, key, pad, rest) =>
    `<text x="632" y="${y}" xml:space="preserve"><tspan fill="${t.amber}">${key}</tspan>${pad}${rest}</text>`;

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" role="img" aria-labelledby="t">
<title id="t">coderachnid. It feels the thread before it snaps. A spider web drawn over code, with one amber thread vibrating where the flaw is.</title>
<style>
@keyframes hum { 0%, 100% { opacity: .55 } 50% { opacity: 1 } }
@keyframes blink { 0%, 49% { opacity: 1 } 50%, 100% { opacity: 0 } }
.hum { animation: hum 2.4s ease-in-out infinite }
.cursor { animation: blink 1.1s steps(1) infinite }
@media (prefers-reduced-motion: reduce) { .hum, .cursor { animation: none } }
</style>
<defs>
<clipPath id="webclip"><circle cx="${cx}" cy="${cy}" r="${R}"/></clipPath>
<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
</defs>
<rect x="0.5" y="0.5" width="${W - 1}" height="${H - 1}" rx="18" fill="${t.bg}" stroke="${t.line}"/>
<g font-family="${MONO}" font-size="11" fill="${t.code}"><g opacity=".07">${code}</g><g opacity=".2" clip-path="url(#webclip)">${code}</g></g>
<g stroke="${t.web}" stroke-opacity=".55" stroke-width="1.2" fill="none">${spokes}${web}</g>
<g filter="url(#glow)"><path class="hum" d="${seg(HI, HR)}" stroke="${t.amber}" stroke-width="3.5" fill="none" stroke-linecap="round"/></g>
<g class="hum" fill="none" stroke="${t.amber}" stroke-width="1.6" opacity=".8"><circle cx="${f(mid[0])}" cy="${f(mid[1])}" r="14" stroke-dasharray="6 8"/><circle cx="${f(mid[0])}" cy="${f(mid[1])}" r="26" stroke-dasharray="4 10" opacity=".6"/></g>
<g font-family="${MONO}" font-size="12" fill="${t.amber}"><line x1="${f(mid[0] + 26)}" y1="${f(mid[1] - 18)}" x2="${f(mid[0] + 70)}" y2="${f(mid[1] - 54)}" stroke="${t.amber}"/><text x="${f(mid[0] + 76)}" y="${f(mid[1] - 58)}">user input → SQL</text></g>
<svg x="${f(cx - sw / 2)}" y="${f(cy - sh / 2)}" width="${sw}" height="${f(sh)}" viewBox="${lx} ${ly} ${lw} ${lh}" overflow="visible">${spider("B", t.outline, THEMES.dark.amber)}</svg>
<g font-family="${MONO}">
<circle cx="636" cy="118" r="5" fill="${t.amber}"/>
<text x="652" y="123" font-size="14" letter-spacing="3" fill="${t.muted}">~/CODERACHNID</text>
<text x="630" y="200" font-size="60" font-weight="800" letter-spacing="-2" fill="${t.text}">coderachnid</text>
<text x="632" y="246" font-size="19" fill="${t.text}">It feels the thread before it snaps.<tspan class="cursor" fill="${t.amber}"> ▌</tspan></text>
<g font-size="15" fill="${t.muted}">
${label(306, "security", "  ", "from the first line")}
${label(336, "tests", "     ", "that can actually fail")}
${label(366, "data", "      ", "never touches the original")}
${label(396, "phases", "    ", "done once, closed clean")}
</g>
<text x="632" y="452" font-size="12" fill="${t.muted}">${SKILL_COUNT} skills · no hooks by default · Claude Code plugin</text>
</g>
</svg>
`;
}

for (const theme of Object.keys(THEMES)) {
  writeFileSync(join(OUT, `logo-${theme}.svg`), logo(theme));
  writeFileSync(join(OUT, `banner-${theme}.svg`), banner(theme));
}
console.log("wrote logo-{dark,light}.svg and banner-{dark,light}.svg");
