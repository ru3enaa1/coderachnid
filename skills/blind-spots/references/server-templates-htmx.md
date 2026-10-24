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
- `@{/x(p=${null})}` writes `p=` (empty) rather than omitting it.
- **`__...__` is preprocessing.** Two BEM classes (`block__element`) in one expression
  break the template. Build the class name in code.
- **Without its framework the engine may switch expression language** (Thymeleaf with
  Spring uses SpEL; on its own, OGNL). Record properties read the same, but list
  selection is written differently and static class access is best avoided. Before
  writing the template, probe the exact expressions you need in a ten-line test.
- Templates and Java changes need a restart. Edited static files are served from the
  build output, so copy them there or restart.
- Fingerprinted static URLs (`app-<hash>.css`): templates always use `@{...}`, and tests
  match with a pattern.

## HTMX

- **A redirect (302) answering an HTMX request** is followed internally, so the whole page
  lands inside `hx-target` and flash attributes are lost. Answer 200 with `HX-Redirect`
  and save the flash by hand.
- `hx-include="closest form"` on an `hx-get` puts the CSRF token in the URL. Include only
  the needed container.
- A form without a field submits it as null: **null = don't touch; empty = clear.**
- Serve HTMX locally, pinned, with its hash recorded. Never from a CDN in an app with a
  strict CSP.
