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
- Use design tokens for every color and size, with both themes defined. No inline
  `style=""` (CSP).

## Accessibility and contrast

- **Measure contrast, don't estimate it.** A test computes the ratio from the tokens.
  Text on glass is measured over the composited glass on top of each tile of the real
  background.
- Severity or state is never color alone: add text and an icon.

## Browsers and capture

- Desktop Chrome won't go narrower than about 500 px, so a `--window-size=390` screenshot
  looks broken without being broken. Use device emulation.
- Headless Edge/Chrome won't take a screenshot when `--enable-logging` is on. Capture
  and log in separate runs.
- A scripted `focus()` doesn't trigger `:focus-visible` in a headless browser. Test it
  with real pointer and keyboard events.
- `navigator.clipboard` doesn't exist without HTTPS (for example a phone on
  `http://192.168.x.x`). Fall back to a hidden textarea plus `execCommand('copy')`, and
  test with the API removed.

## Numbers

- JS `Math.round(n*100)/100` and Java `%.2f` disagree on x.xx5 values. Round once, on
  one side, with a tested rule.
