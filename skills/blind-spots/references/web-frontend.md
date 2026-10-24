# Web frontend pitfalls

## CSS

- **Style by class, always.** Styling bare elements from a parent block overrides
  children that already have a class (this cascade bug came back four times).
- The `padding:` shorthand overrides a `padding-bottom` that the layout reserves (for
  example space for a mobile tab bar). Use `padding-top` / `padding-inline`.
- **`backdrop-filter` or `transform` on an ancestor makes `position: fixed` relative to
  that ancestor.** Put the glass effect on a sibling layer.
- A `z-index` on the main content creates a stacking context. A fixed panel inside it
  cannot cover the header.
- A `<fieldset>` with `display: grid` and a max height collapses its rows in Chrome.
  Put the grid in a container inside the fieldset.
- A utility class that sets `position: relative` must come before any rule that
  positions the same element differently.
- **Screen-reader-only labels positioned absolutely stretch a scrolling container** that
  is not their containing block. Make the scroller `position: relative`.
- Under a strict CSP with no inline styles, position chart marks with **SVG attributes**
  (`x`, `width`), which are not styles.
- Use design tokens for every color and size, with both themes defined. No inline
  `style=""` (CSP).
- Don't copy fixed heights from a desktop mockup. A panel designed at 1440×900 runs off
  a 1536×737 viewport (1080p at 125%). Use `min(<mockup height>, 100dvh − header −
  footer)` and check at the real viewport.

## Accessibility and contrast

- **Measure contrast, don't estimate it.** A test computes the ratio from the tokens.
  Text on glass is measured over the composited glass on top of each tile of the real
  background.
- Severity or state is never color alone: add text and an icon.

## Browsers and capture

- Desktop Chrome won't go narrower than about 500 px, so a `--window-size=390` screenshot
  looks broken without being broken. Use device emulation.
- **Test at the user's real sizes, not a standard list.** OS scaling shrinks the
  viewport (1080p at 125% is 1536×737), and a screenshot from the user can reveal an
  in-between size the design never planned for. Add it to the checked sizes.
- **A clean profile still loads extensions installed for the whole machine** (one wallet
  extension flooded the console). Launch the test browser with extensions disabled.
- **A one-time key is spent by the first tool that uses it.** Order the review tools, or
  restart the app between them.
- **Check for overlap geometrically.** "No horizontal scrollbar" misses two components
  painted on top of each other. Compare their bounding rectangles in the browser and fail
  when any two intersect.
- Headless Edge/Chrome won't take a screenshot when `--enable-logging` is on. Capture
  and log in separate runs.
- Headless Edge/Chrome without its own `--user-data-dir` can hand off to the user's
  running browser and return at once, with no screenshot. Pass a dedicated profile
  folder and check that the output file exists. Confirmed 2026-10-13.
- An SVG shown through `<img>` (a README, an `<img src>`) cannot load web fonts or run
  scripts. Use a system font stack or convert the text to paths. Anticipated.
- A scripted `focus()` doesn't trigger `:focus-visible` in a headless browser. Test it
  with real pointer and keyboard events.
- `navigator.clipboard` doesn't exist without HTTPS (for example a phone on
  `http://192.168.x.x`). Fall back to a hidden textarea plus `execCommand('copy')`, and
  test with the API removed.

## Numbers

- JS `Math.round(n*100)/100` and Java `%.2f` disagree on x.xx5 values. Round once, on
  one side, with a tested rule.

## Generated art

- **Green tests on generated art say nothing about how it reads.** Every test passed
  while a drawing was plainly wrong. Keep the golden as a viewable sheet (HTML with every
  variant), capture it at 3× and look before closing.
- **Brand characters as one parametric formula**, not one drawing per case: the
  silhouette fixed by category, the expression driven by the case's data. Each piece is
  unique without randomness and reproducible. Describe third-party references in words
  in the brief instead of attaching their images to a generator.
