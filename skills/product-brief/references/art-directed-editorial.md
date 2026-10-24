# Art-Directed Editorial

A design direction for landing pages and product sites that read like a magazine cover:
one crafted image, very large type, and almost nothing else. It is a starting point for
`product-brief` when the user has no visual identity yet, and a vocabulary for
describing one when they do. The user's own logo, type, colors and references always
override it.

The families below were distilled from a set of modern landing pages collected as
inspiration. They describe patterns, not sources: never name or imitate a
specific site, and never reuse its art.

## Eight rules every family shares

1. **One crafted hero visual.** A 3D render, an engraving, a matte painting or line
   art made for this product. Never generic stock photography: it is the first thing
   that makes a page look like every other page.
2. **Oversized display type with family contrast.** Either a serif with italic accents
   or a tightly tracked grotesk, set very large. The headline has six words or fewer.
3. **A restricted palette.** Neutrals plus **one** accent (for example blue, neon green,
   coral or gold). A second accent dilutes the first.
4. **Generous negative space and one primary call to action**, dark and pill-shaped.
   Secondary actions are text links.
5. **Micro-typography.** Tiny uppercase or monospace labels, section numbering such as
   01 / 02, hairline grid rules. It signals care at a glance.
6. **Layering.** Type crossing the image; translucent glass cards floating on top.
7. **Subtle texture.** Film grain, a dot grid or a haze, kept faint enough that text
   stays sharp.
8. **One signature detail** that people remember: a rotating circular text badge,
   coordinates, a live counter. One, not three.

## Four families

| Family | What it looks like | Traits | Fits |
|---|---|---|---|
| **Technical Neo-Swiss** | a voxel or wireframe figure set behind giant lowercase type on a visible column grid | visible grid, monochrome base, one giant number or word, voxel or wire art, vertical labels, a neon accent | studios, agencies, developer tools, data products |
| **Blueprint Engraving** | an antique-style line engraving with one zone in duotone | engraved line art, partial duotone, dot grid, a classic serif | regulated finance, legal, insurance: wherever trust and heritage sell |
| **Atmospheric Scene** | a full-bleed scene: a city above pastel clouds, dark monoliths in a warm glow, a painted mountain range | full-bleed photo, matte painting or illustrated scene, type set in the sky, dramatic light | B2B software, AI products, aspirational brands, wellness |
| **Hero Object** | one soft or liquid rendered object (a glass ribbon, a miniature house with warm windows, a portrait ringed by floating cards) | a single rendered object, floating glass cards, a serif with italics | consumer apps, hardware, products with a tangible "thing" |

## Choosing a family

- **Start from the niche** (the "Fits" column), then **look at the competitors** in
  `docs/MARKET.md`. If they all share one look, that look is the category default:
  aim for the free visual position, the family nobody in the category uses that the
  customer will still trust.
- **Mixing is allowed** when it has a reason: an Atmospheric Scene with Neo-Swiss
  micro-typography, a Hero Object with an engraved texture. Keep the eight rules,
  above all one accent and one signature detail.
- **The user's material wins.** A logo, a typeface or a color they already own decides
  the family, not the other way round.

## Skeleton to output when the user has no identity

- Family, and the one-line reason (niche + distance from the competitors).
- Type pairing: display face and text face, with sizes for the headline, body and labels.
- Palette: neutrals and the one accent, as hex, with the contrast ratio of body text.
- Hero visual concept: subject, medium, light, the zone where the headline sits.
- Signature detail.
- Section-by-section layout for desktop and mobile, and the states of key screens.
- The mockup prompt, describing every element above.

## Guardrails

- **Social proof is a placeholder until real.** User counts, "trusted by" rows, client
  logos and testimonials are marked as placeholders in the mockup and never shipped
  invented.
- **Contrast.** Text over photos, scenes and glass cards passes WCAG 2.2 AA; add a scrim
  or move the text when it doesn't.
- **Weight.** 3D renders and full-bleed scenes are heavy: give the hero a weight budget,
  serve modern image formats at the sizes the layout uses, and have a still fallback.
  Respect reduced-motion settings for any animation, including the signature detail.
- **Rights.** Generated art is original to the product. The references that inspired a
  direction are never used as assets or traced.
