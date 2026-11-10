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
- **A one-column grid inside a fixed-height container squeezes its rows until they
  overlap.** At a narrow width two columns stacked into one, and a list covered the
  primary button. Switch to a scrolling flex column there (`display: flex;
  flex-direction: column; overflow: auto`, children `flex: none`) and look at the narrow
  capture of every new screen.
- **Size fixed-height boxes for their text at the smallest viewport.** Text that runs out
  of a fixed-height box is neither clipped nor overlapping, so the automated layout check
  passed; only the screenshot showed a label sitting on the box's border.

## Accessibility and contrast

- **Measure contrast, don't estimate it.** A test computes the ratio from the tokens.
  Text on glass is measured over the composited glass on top of each tile of the real
  background.
- Severity or state is never color alone: add text and an icon.
- **`aria-current="page"` belongs to the main navigation only.** Tabs that also said
  `page` gave the page two "current pages" (a test caught it). Tabs and in-page lists use
  `aria-current="true"`.

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
- **Collision checks compare element boxes, not what the elements draw.** Art that
  overflows its box on purpose (an SVG with `overflow: visible`) touched the text beside
  it, and the check said "fine". Capture and look whenever art is placed outside its
  container. Each kind of breakage needs its own check: `../../tests-that-bite/references/test-traps.md`.
- **What the user must see goes above the fold.** An automated layout check accepts
  scrolling inside a panel, which is correct, so it passed while the key element sat
  below the fold at 1366×657. Look at the smallest real screen.
- **Prepare a capture's state through the browser's debugging protocol**
  (`Runtime.evaluate` over CDP is not bound by the page's CSP). Never relax the app's
  CSP for a tool.
- **State held by the server outlives the script.** A capture script that opened a record
  found it still open on its second run, and waited forever for an "open" form that was
  no longer there. Check the server's state before preparing, or start it fresh.
- Headless Edge/Chrome won't take a screenshot when `--enable-logging` is on. Capture
  and log in separate runs.
- Headless Edge/Chrome without its own `--user-data-dir` can hand off to the user's
  running browser and return at once, with no screenshot. Pass a dedicated profile
  folder and check that the output file exists. Confirmed 2026-10-13.
- An SVG shown through `<img>` (a README, an `<img src>`) cannot load web fonts or run
  scripts. Use a system font stack or convert the text to paths. Anticipated.
- A scripted `focus()` doesn't trigger `:focus-visible` in a headless browser. Test it
  with real pointer and keyboard events.
- `navigator.clipboard` doesn't exist without a secure context (for example a phone on
  `http://192.168.x.x`, or a native shell's custom origin). Fall back to a hidden
  textarea plus `execCommand('copy')`, and test with the API removed.

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
