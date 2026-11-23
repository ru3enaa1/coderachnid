# Windows shell pitfalls

## PowerShell 5.1

- `&&` and `||` do not exist. Use `A; if ($?) { B }`.
- Redirecting a native command's stderr (`2>&1`, `*>`) wraps each line in a
  `NativeCommandError` and sets `$?` to false **even when the build passed**. Trust
  `$LASTEXITCODE`, not the red text.
- `Set-Content` defaults to the ANSI code page. Pass `-Encoding utf8` explicitly.
- **A `.ps1` without a BOM is read as ANSI**, so accented literals in it don't match, and
  neither does a symbol such as `·`: a wait for a window title containing one ran to its
  timeout. Save scripts as UTF-8 with BOM, or match around the symbol (`-like "App*Home"`).
  A template with accents that such a script writes lives in its own file.
- **`Start-Process -ArgumentList @(...)` does not quote its arguments.** A folder under
  `C:\Users\First Last` arrived split in two, and the program exited complaining about an
  extra argument. Quote each path by hand (`` "`"$path`"" ``). Java's `ProcessBuilder`
  does quote.
- **Double quotes inside an argument to a native program get eaten.** A commit message
  with quotes reached `git` split: the pieces were read as paths (`pathspec '...' did not
  match`), the commit didn't happen, and what was staged went into the next commit. A
  `docker inspect` template with `"..."` failed with *bad character '='*. Write commit
  messages to a file (`git commit -F <file>`), and ask tools for JSON
  (`{{json ...}}` piped to `ConvertFrom-Json`) instead of quoting inside a template.
  Confirmed 2026-11-09.
- **A `.ps1` with `$ErrorActionPreference = "Stop"` dies when its output is redirected**:
  native tools that print warnings on stderr (Maven does) become terminating errors.
- PowerShell splits `-Dkey=path/file.txt` at the dot, and Maven then reads `.txt` as a
  build phase. Quote every `-D` argument that contains a dot.

## Processes

- `taskkill /IM java.exe` (or `node.exe`, `msedge.exe`) kills **every** instance,
  including other projects and the user's own browser. Find the PID by port
  (`Get-NetTCPConnection -LocalPort <port>`) or by command line, then stop that PID.
- A headless browser driven over a debugging port leaves child processes alive if you
  kill only the parent, and they lock the profile folder. Close it with the protocol's
  close command, or by PID filtered on the profile path.
- **Two processes can't write the same log file.** A development server being stopped kept
  writing for a few seconds, and the new one failed to start, with no message. Give each
  start its own log file.

## Environment

- User environment variables set after a terminal opened are not visible in it. Read
  them with `[Environment]::GetEnvironmentVariable('NAME','User')`, or open a new shell.
- When two projects need different JDK, Node or Python versions, use a toolchain or a
  per-session script. Never repoint the global `JAVA_HOME` (or equivalent) that another
  project depends on.
- Home folders with spaces (`C:\Users\First Last`) break unquoted paths in JVM
  `argLine`s, Java agents and scripts.
- **Some settings split on spaces however they are quoted.** OpenSSH's
  `UserKnownHostsFile` takes several files separated by spaces, so a path under
  `C:\Users\First Last` became two paths, quotes or `~` notwithstanding, and the host key
  was never saved. Use the folder's 8.3 short name (`/c/Users/FIRSTL~1/...`, from
  `cmd /c for %I in ("<path>") do @echo %~sI`).
- **Docker Desktop updates itself when it starts and restarts its engine.** A `docker
  compose up` right after switching it on saw the database stop cleanly (SIGTERM, no
  out-of-memory, no restart counted) and lose its earlier events. Before blaming the
  container, read Docker's own log (`%LOCALAPPDATA%\Docker\log\host`).
- The Windows firewall drops packets silently. Connecting to a port that is not
  listening on the LAN address **times out** instead of being refused, so a test that
  proves "not reachable from the network" must accept both outcomes.

## Git Bash / MSYS

- Arguments containing `=/` get rewritten as Windows paths (`x=/` becomes
  `x=C:/Program Files/Git/`), and so does a leading `/`: `claude -p "/output-style"`
  arrived as `C:/Program Files/Git/output-style`. Prefix **that one command** with
  `MSYS_NO_PATHCONV=1`. Never export it for a whole script: it also stops the conversion
  other tools need, and `git -C "/c/Users/..."` then fails, so a reset step silently
  did nothing. Confirmed 2026-10-14.
- Heredocs and `sed` can eat backslashes: `\d` loses its slash and `\v` becomes a vertical
  tab. Write code, regexes and Windows paths with a file-editing tool. A heredoc turned
  `[\\/]` into `[\/]` in a YAML file, a class that never matches a Windows path, and
  inline code (`node -e`) lost the backslashes of a regex. Confirmed again 2026-10-13.
  Even a heredoc feeding an interpreter (`python - <<'EOF'`) lost them in an agent
  session: a `\\n` became a real line break inside generated code (2026-11-09).
- **Git for Windows ships GNU grep 3.0, which aborts (exit 134) on `-i` combined with
  more than one pattern** (`-f file` or several `-e`). Inside a loop, that abort looks
  like "no match", so a privacy or lint check passes without checking anything. Lowercase
  both sides and drop `-i`, treat any grep exit above 1 as an error, and run the check
  once against a planted term. Confirmed 2026-10-13.
- **The same grep strips the carriage return at the end of each line before matching**,
  so `grep $'\r'` never finds a CRLF file and a line-ending check reports "clean". Count
  CRs with `tr -cd '\r' < file | wc -c` (or use `grep -U`), and prove the check on a
  planted CRLF file. Confirmed 2026-10-13.
- **Windows paths stop at 260 characters by default.** A `git clone` into a deeply
  nested folder (a temp or scratch directory) fails with `Filename too long`, and a tool
  that falls back to SSH then reports a confusing access error. Test in a short path, or
  set `git config --global core.longpaths true`. Confirmed 2026-10-14 while testing a
  plugin install from GitHub.
- A Python heredoc in Git Bash may read the text as cp1252, so a replacement with accents
  finds nothing. Edit accented documents with a file tool.
- Windows Python cannot see Git Bash's `/tmp`. Convert paths with `cygpath -w`.
- Tools installed for Windows (Node, Docker) may be missing from Git Bash's `PATH` in
  agent sessions. Prepend their install folder explicitly.
- A tool shipped inside an editor extension lives in a versioned folder
  (`.../extension-2.1.296/...`) that disappears on the next auto-update. Find it with a
  glob each time, and make "tool not found" fail loudly: a check piped into `grep` that
  can't start prints nothing, which reads like a pass. Confirmed 2026-10-14.

## Line endings

- `core.autocrlf` / `text=auto` converts generated files to CRLF on checkout, which
  breaks byte-for-byte comparisons. Pin them (`*.svg text eol=lf`, golden files) in
  `.gitattributes` and verify on a fresh clone.
- **A folder-wide `text eol=lf` rule corrupts binaries placed there later** (a PDF golden
  in the goldens folder). Add a `binary` exception for them *after* the folder rule.

## Display

- At 125% scaling, a 1920×1080 screen gives a 1536×737 browser viewport. Also check
  1366×657.
