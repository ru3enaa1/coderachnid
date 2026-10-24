# Generated documents and PDF

For reports, invoices or certificates rendered from HTML to the screen and to PDF. Most of
these traps pass every test and only show when someone looks at the page.

## Build the document before the page

- **Model before view.** Build the document as an immutable model with every text and
  every figure already written, and test it without rendering anything. Templates only
  place it, so banned phrases, ranges and provenance are checked on the whole text before
  the first page exists.
- **Describe the snapshot, not the present.** A report about a stored computation
  describes what the computation read, from its saved canonical input. If reference data
  changed since, the report says so in a notice.
- **Never show "coming soon" to the end client.** What doesn't exist yet doesn't appear,
  neither in the document nor in its table of contents.

## One stylesheet for two engines

- **Write the CSS for the most limited reader.** When one HTML feeds the screen and a
  PDF engine, use only what the PDF engine understands (blocks, tables, `inline-block`,
  absolute positioning; no flex, grid, custom properties or gradients) and draw decoration
  as SVG. Decide this before the first rule, not when the PDF comes out broken.
- **Some HTML-to-PDF engines parse only XML.** The template must render well-formed:
  void tags closed, only the five XML entities, `xmlns` on every `<svg>`. A test parses
  the output as XML, with external entities disabled.
- **`@media` blocks go after the base rules they override.** With equal specificity the
  rule further down wins; a print block placed first is ignored. An element running in a
  page margin must appear in the document before the content of its page.
- **Decoration is checked in the target engine.** An absolute SVG behind the text showed
  in the browser and not in the PDF. A form that works in both (stripes in the flow)
  beats one that needs adjusting twice.

## Fonts and accessibility

- **Never assume a font has a glyph.** Check every symbol the product uses against the
  font (`canDisplay` or equivalent), add a fallback font only for the missing ones, and
  assert the PDF text has no replacement character. On screen a system font fills the
  gap silently.
- **An empty `alt` isn't "decorative" for every engine.** Some PDF/UA engines count it as
  missing and can't mark artifacts. Give decorative-but-meaningful marks a short text that
  makes sense read aloud.

## Look at the pages

- **Review the PDF page by page as images.** A temporary test renders each page to PNG
  with the same PDF library; look at them, then delete the temporary test and keep the
  PDF golden. This finds footers in mid-page, lost patterns and missing glyphs.
- **For the HTML version, take one tall headless screenshot and cut it per page.** A
  caption pushed under headings by `display: block`, whitespace between `inline-block`
  items breaking a row, and long citations stretching a narrow table only show there.
- **Keep the rendered document itself as the golden**, next to the data golden, so a
  change can be read as a diff and also opened in a browser.
- **A golden that depends on a content hash changes with any content edit.** Regenerate
  it with an explicit command and review the diff in the same commit.

## Framing and silence

- **Frame only the one route that needs it.** To show the document inside the app
  without mixing styles, an `<iframe>` from the same app works; how to allow it for that
  route alone: `../../security-first/references/local-web-app.md`.
- **Silence a library's console logging without losing its diagnostics.** A global
  "logging off" switch may also drop the diagnostics each document receives, and a
  "zero warnings" test then passes vacuously. Replace the library's logger with a mute
  one and keep a positive control that must produce a warning.
