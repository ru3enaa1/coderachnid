# Design brief · RecallKit · 2026-10-22

Requirements: `docs/PRD.md`.

### What the competitors look like
Competitors A, B and D use clinical blue and white, stock photos of smiling dentists and
dense feature grids; C and E use plain SaaS dashboards. Category default: blue-white
clinic template. Free visual position: a warm, editorial look no competitor uses.

### Branding skeleton (proposal: the owner has no logo or type yet)
- Family: Hero Object, because a single tangible object (a soft rendered appointment
  card) reads as calm and stands apart from the stock-photo default.
- Type: a serif with italic accents for display (72/56 px), a grotesk for text (17 px),
  monospace labels (11 px uppercase).
- Palette: #F4EFE6 background, #1E1C1A ink, #8A8378 muted, one accent #D9643A (terracotta).
  Body text contrast 15.8:1.
- Hero visual: a soft clay appointment card floating over a warm haze, headline across
  its lower edge.
- Signature detail: a small rotating badge "next recall in 6 months".

### Layout
Desktop: hero (headline "Patients come back", one dark pill CTA "Start a recall"),
three numbered steps 01/02/03, pricing (three tiers), FAQ, footer. Mobile: same order,
one column, CTA sticky at the bottom. States: empty campaign list ("No campaigns yet:
start your first recall"), loading skeletons, send error with retry, success toast.

### Mockup prompt
```
Landing page for RecallKit, desktop 1440 px and mobile 390 px. 12-column grid, 96 px
margins. Background #F4EFE6, ink #1E1C1A, one accent #D9643A. Hero: a soft clay
appointment card floating over a warm haze; headline "Patients come back" in a serif,
72 px, italic on "back", crossing the card's lower edge; one dark pill button "Start a
recall". Below: steps 01/02/03 with monospace labels, hairline rules; pricing with three
tiers (Reminders USD 19, Recall USD 39 highlighted, Clinic USD 59); a rotating circular
badge "next recall in 6 months"; faint film grain. Testimonials row as a grey
PLACEHOLDER box.
```

### Guardrails
- Social proof (testimonials, clinic counts, logos) is a marked PLACEHOLDER until real.
- Text over the hero passes WCAG 2.2 AA; the hero image stays under 200 KB with a still
  fallback; motion respects reduced-motion.
- Generated art is original; references are not reused.
