# Windows shell pitfalls

## PowerShell 5.1

- `&&` and `||` do not exist. Use `A; if ($?) { B }`.
- Redirecting a native command's stderr (`2>&1`, `*>`) wraps each line in a
  `NativeCommandError` and sets `$?` to false **even when the build passed**. Trust
  `$LASTEXITCODE`, not the red text.
- `Set-Content` defaults to the ANSI code page. Pass `-Encoding utf8` explicitly.
- PowerShell splits `-Dkey=path/file.txt` at the dot, and Maven then reads `.txt` as a
  build phase. Quote every `-D` argument that contains a dot.

## Processes

- `taskkill /IM java.exe` (or `node.exe`, `msedge.exe`) kills **every** instance,
  including other projects and the user's own browser. Find the PID by port
  (`Get-NetTCPConnection -LocalPort <port>`) or by command line, then stop that PID.
- A headless browser driven over a debugging port leaves child processes alive if you
  kill only the parent, and they lock the profile folder. Close it with the protocol's
  close command, or by PID filtered on the profile path.

## Environment

- User environment variables set after a terminal opened are not visible in it. Read
  them with `[Environment]::GetEnvironmentVariable('NAME','User')`, or open a new shell.
- When two projects need different JDK, Node or Python versions, use a toolchain or a
  per-session script. Never repoint the global `JAVA_HOME` (or equivalent) that another
  project depends on.
- Home folders with spaces (`C:\Users\First Last`) break unquoted paths in JVM
  `argLine`s, Java agents and scripts.
- The Windows firewall drops packets silently. Connecting to a port that is not
  listening on the LAN address **times out** instead of being refused, so a test that
  proves "not reachable from the network" must accept both outcomes.

## Git Bash / MSYS

- Arguments containing `=/` get rewritten as Windows paths (`x=/` becomes
  `x=C:/Program Files/Git/`). Prefix the command with `MSYS_NO_PATHCONV=1`.
- Heredocs and `sed` can eat backslashes: `\d` loses its slash and `\v` becomes a vertical
  tab. Write code, regexes and Windows paths with a file-editing tool. A heredoc turned
  `[\\/]` into `[\/]` in a YAML file, a class that never matches a Windows path, and
  inline code (`node -e`) lost the backslashes of a regex. Confirmed again 2026-10-13.
- **Git for Windows ships GNU grep 3.0, which aborts (exit 134) on `-i` combined with
  more than one pattern** (`-f file` or several `-e`). Inside a loop, that abort looks
  like "no match", so a privacy or lint check passes without checking anything. Lowercase
  both sides and drop `-i`, treat any grep exit above 1 as an error, and run the check
  once against a planted term. Confirmed 2026-10-13.
- Windows Python cannot see Git Bash's `/tmp`. Convert paths with `cygpath -w`.
- Tools installed for Windows (Node, Docker) may be missing from Git Bash's `PATH` in
  agent sessions. Prepend their install folder explicitly.

## Line endings

- `core.autocrlf` / `text=auto` converts generated files to CRLF on checkout, which
  breaks byte-for-byte comparisons. Pin them (`*.svg text eol=lf`, golden files) in
  `.gitattributes` and verify on a fresh clone.

## Display

- At 125% scaling, a 1920×1080 screen gives a 1536×737 browser viewport. Also check
  1366×657.
