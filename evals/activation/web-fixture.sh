#!/usr/bin/env bash
# Shared scaffold for cases about server templates and CSS: the notes sample plus a
# Thymeleaf template and a stylesheet. The template carries one trap on purpose:
# `<` inside a th:* attribute, which the template parser reads as the start of a tag
# (use `lt`). The stylesheet's fixed footer covers the last button on short screens.
# The trap is listed here, never in the files the agent reads.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/sandbox/." .
mkdir -p templates static
cat > templates/notes.html <<'HTML'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="utf-8">
  <title th:text="${title}">Notes</title>
  <link rel="stylesheet" th:href="@{/site.css}">
</head>
<body>
  <main class="notes">
    <h1 th:text="${title}">Notes</h1>
    <p class="notes__count" th:if="${count < 100}" th:text="${'Total: ' + count}">0</p>
    <ul class="notes__list">
      <li th:each="note : ${notes}">
        <a th:href="@{/notes/{id}(id=${note.id})}" th:text="${note.title}">note</a>
      </li>
    </ul>
    <button class="notes__new" type="button">New note</button>
  </main>
  <footer class="site-footer">Notes</footer>
</body>
</html>
HTML
cat > static/site.css <<'CSS'
main { padding: 16px; }
.notes__new { margin-top: 24px; }
.site-footer { position: fixed; bottom: 0; left: 0; right: 0; height: 64px; }
CSS
