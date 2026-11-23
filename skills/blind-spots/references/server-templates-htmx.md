# Server-side templates (Thymeleaf) and HTMX pitfalls

These break at render time, not at compile time.

## Thymeleaf

- Never nest `${...}` inside `${...}`. Use one expression: `${cond ? a : b}`.
- Inside `th:*` attributes use `lt` / `gt` / `le` / `ge`, never `<` / `>`.
- `#aggregates` has `sum` and `avg`, but no `max` or `min`. Precompute them in the service.
- **`th:replace` runs before `th:if` on the same tag**, so the condition is ignored. Wrap
  it in a `th:block`.
- A `th:fragment` defined inside a page also renders where it is defined. Put reused
  fragments in their own file.
- **HTML comments are sent to the browser.** Never write in them what the page must not
  say.
- Accented characters are written as entities in attributes and in `<textarea>`.
  Tests compare against what is actually emitted.
- Attribute order is not preserved, so tests use a regex instead of a literal string.
- A form that is re-rendered needs a class with getters and setters. `th:field` reads
  JavaBean getters, so a `record` doesn't work.
- **A checkbox with `th:field` gets a hidden `<input name="_field">` right after it**, so
  a style like `input:checked + label` no longer reaches the label (checked boxes looked
  unchecked). Use the general sibling selector `~`, which works with and without it.
- **A `LocalDate` in a `th:field` of `type="date"` needs `@DateTimeFormat(iso = DATE)`**:
  without it the value is printed in the locale's format (`12/5/26`) and the browser
  shows an empty field. A screenshot found it, not a test: assert the `value` attribute.
- `@{/x(p=${null})}` writes `p=` (empty) rather than omitting it.
- **`__...__` is preprocessing.** Two BEM classes (`block__element`) in one expression
  break the template. Build the class name in code.
- **Without its framework the engine may switch expression language** (Thymeleaf with
  Spring uses SpEL; on its own, OGNL). Record properties read the same, but list
  selection is written differently and static class access is best avoided. Before
  writing the template, probe the exact expressions you need in a ten-line test.
- **With Spring, SpEL only calls public methods.** A package-private view `record` failed
  at render time with "method cannot be found", although it had the method. Make view
  models `public record`s with public methods. OGNL (the engine without Spring) reads them.
- Templates and Java changes need a restart. **Where an edited stylesheet is served from
  depends on how the app runs.** One project served static files from the build output
  (copy them there, or restart); another, under `spring-boot:run`, served them straight
  from the source folder, where touching the build output changes nothing. A packaged jar
  needs repackaging. Check which before "fixing" a stale stylesheet. **Copying is not
  enough for a stylesheet with `url(...)` inside** when Spring rewrites static URLs: its
  transformer cache keeps the rewritten bytes per file, not per content hash, so the new
  URL serves the old CSS. Restart.
- Fingerprinted static URLs (`app-<hash>.css`): templates always use `@{...}`, and tests
  match with a pattern.

## HTMX

- **A redirect (302) answering an HTMX request** is followed internally, so the whole page
  lands inside `hx-target` and flash attributes are lost. Answer 200 with `HX-Redirect`
  and save the flash by hand.
- `hx-include="closest form"` on an `hx-get` puts the CSRF token in the URL. Include only
  the needed container.
- A form without a field submits it as null: **null = don't touch; empty = clear.**
- **Update a part of the page that a response doesn't target with `hx-swap-oob`** (for
  example a footer that follows a preview). The out-of-band element goes only in the
  fragment's response, never in the full page, or the page has two elements with one id.
- **`HX-Reswap: none` leaves the target untouched and still applies out-of-band swaps**:
  useful to keep the figures on screen while only a warning and a button change.
- **A button outside its form names it with `form="id"`**: `button.form.requestSubmit()`
  works, and HTMX includes that form's fields in the button's `hx-post`.
- Serve HTMX locally, pinned, with its hash recorded. Never from a CDN in an app with a
  strict CSP.
