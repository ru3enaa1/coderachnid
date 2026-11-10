# Desktop apps: native window, installer and release

For a local web app shipped as a desktop program: a native shell that shows the app in
the system webview instead of a browser window, an installer, and a release that other
people download. Each trap below was found in a real project, and most of them passed
every test. Hardening the server itself: `../../security-first/references/local-web-app.md`.

## The window

- **Keep the server in charge and swap only the window launcher.** The shell replaces
  the browser window and nothing else, so the app still opens in a browser when the shell
  is absent (in development, for example).
- **Grant the page a closed list of window permissions** (minimize, maximize, close,
  drag, set the title), scoped to the exact origin of the session. Anything else stays
  out of reach of the page.
- **The window starts first.** A splash or an error screen can only be shown by a process
  that is already up. The shell starts, shows its own waiting page and launches the server
  as a child; the server prints its one-time link on a tagged stdout line (never in a file
  another process could read); the server watches its parent and shuts down when the
  window ends.
- **Give each start a generation number**, so a stale attempt can't navigate the window
  after the user pressed "try again".
- **The webview caches CSS and JS in its data folder.** A script broken on purpose did not
  break the window that reused its folder, so the positive control passed for the wrong
  reason. Run controls on a fresh data folder, and give static files content-hash URLs in
  production so an update can never keep serving the old ones.
- **Smoke-test the real window by clicking the page's own buttons** and asserting the
  window's state (minimized, maximized, closed), and prove the test once with a broken
  button.
- **A custom-scheme origin may not be a secure context** (`http://<app>.localhost` in some
  shells): `navigator.clipboard` is missing there. Fall back to a hidden textarea and
  `execCommand('copy')`.
- **A `@font-face` without `font-display: swap` blanks the splash on a cold start.** The
  webview hides the text until the font loads, for up to about three seconds. It never
  showed in development; a capture of the installed app at about one second showed it.

## Capturing the window

- **Never capture the whole screen** to check a window: the person's other windows end up
  in the image. Copy only the window's rectangle, only while it is in front
  (`GetForegroundWindow` on Windows), and delete the image afterwards.
- **Ask the window manager for the rectangle.** On Windows 10, `GetWindowRect` includes an
  invisible border, so the capture took a strip of the desktop; `DwmGetWindowAttribute`
  with `DWMWA_EXTENDED_FRAME_BOUNDS` (9) gives the visible frame.
- **`PrintWindow` skips the webview's `backdrop-filter` layers.** Copy the rectangle from
  the screen instead.

## The installer

- **Check where the packager installs before shipping.** A per-user default of
  `%LOCALAPPDATA%\<product name>` (Tauri's NSIS target) was, case-insensitively, the
  app's own data folder. Install the program under `...\Programs\<name>` and keep the
  data apart.
- **Gate a trimmed runtime with a real document.** A Java runtime trimmed to what `jdeps`
  listed (then `jlink`) silently lost its locale data: a report said "4.93" instead of
  "4,93", with no error. The packaging step produces one real document with the trimmed
  runtime and one with the full JDK and compares them byte for byte; a control run that
  drops the module must fail. Modules the scanner adds that the app never uses are left
  out with a written reason.
- **Packaging-only resources go in a packaging-only configuration**, merged when the
  installer is built. In the main configuration, every development build demanded them.
- **Signing is a switch driven by an environment variable.** Until the real certificate
  exists, prove the signing path with a throwaway self-signed one.
- **A wizard window can be dragged off-screen mid-install**, which left its finish button
  under the taskbar. Re-center the last page when the window is outside the monitor's
  work area.
- **Pin the shell's own toolchain in its folder** (a toolchain file), never globally. The
  first release build can take a quarter of an hour while it downloads and compiles.

## The release

- **The checksum next to a download comes from that exact file**, computed by the build,
  never typed by hand. Never rebuild an artifact that was already shared just to test the
  release script: details in `../../security-first/references/supply-chain.md`.
- **Release screenshots come from a script kept in the repository**, never from a temp
  folder (one almost got lost there), run against a neutral data folder with invented
  sample data. Look at every image before publishing: the first batch showed absolute
  paths with the developer's user name. Delete the folder afterwards.
- **A scripted state change for a before/after pair must be valid for its field.** A
  value outside its range was rejected silently, and the "after" screen never happened.
