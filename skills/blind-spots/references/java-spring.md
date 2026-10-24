# Java, Maven and Spring Boot pitfalls

## Java

- **Static fields initialize top to bottom.** A `static final` that uses another static
  declared further down the class reads its default (`null`, `0`), with no compile error.
  Declare dependencies first, or compute in a static method. A unit test that touches the
  class catches it.

## Build

- **Never `mvn clean` while the app runs from `target/`.** The live JVM loses its
  classes and templates. The tell is two unrelated templates failing at once, one of them
  the error page. Rebuilding won't fix that JVM: restart it.
- `verify` fails if the app is running from the jar in `target/`: the repackage step
  cannot rename it, **even with all tests green**.
- `-DskipTests` does not skip JaCoCo. `install` reaches `verify` and checks coverage
  with stale data. Add `-Djacoco.skip=true`.
- `dependency:build-classpath -pl <module>` cannot find reactor SNAPSHOTs. Add `-am`
  and `package` in the same run, with one output file per module.
- `spring-boot.run.arguments` splits on commas, so `1366,657` becomes two arguments.
  Use `1366x657`. In the other direction, a comma did *not* separate two arguments:
  pass several properties to `spring-boot:run` as environment variables instead.
- **Packaging only the app module can keep a stale copy of a changed sibling module**
  inside the executable jar, and reproducible builds hide it by fixing timestamps. Delete
  the app jar before packaging and check the new class is inside.
- **A native library loaded with `System.load`** (some JDBC drivers do) triggers a
  warning on recent Java, and will be blocked: add `Enable-Native-Access: ALL-UNNAMED`
  to the jar manifest and confirm the repackage step keeps it.
- A Maven wrapper that pins the `.zip` checksum fails with "distribution might be
  compromised" when `unzip` is missing and it downloads the `.tar.gz`. Install `unzip`
  in the container.

## Spring Boot

- **Unresolved `@Value("${SECRET}")` stays as the literal text**, which could pass as a
  valid secret. Validate secrets at startup.
- Spring Boot starts headless. `Desktop.browse` needs `setHeadless(false)`.
- Anything that reads `local.server.port` at startup must tolerate its absence in MockMvc
  tests.
- `HttpStatusEntryPoint` sets 403 without going through the error page (the body is
  empty). Use an entry point that calls `sendError(403)`.
- `getServletPath()` can be empty. A security filter compares `getRequestURI()` minus
  the context path.
- Jackson 3 moved to the `tools.jackson` package. Libraries on Jackson 2
  (`com.fasterxml`) can coexist, so don't copy imports blindly between projects.
- Spring Data ignores repositories nested inside other classes: one repository per file.

## Testing the web layer

- **`MockMvc.param()` appends a value, it doesn't replace it.** To test an empty field,
  rebuild the parameters. Otherwise the test passes without testing anything.
- A real Tomcat redirects with an absolute URL and MockMvc with a relative one, so
  compare the path. Spring Security 7 redirects relatively.
- Without `Accept: text/html`, Spring answers errors as JSON. Error-page tests must ask
  like a browser.
- `?flag` with no value is `""` in Tomcat and `null` in MockMvc. Use
  `getParameterMap().containsKey(...)`.
- `@WebMvcTest` slices need mocks for every bean a `@ControllerAdvice` touches.
- An HTTP client for a third-party API is tested against the JDK's `HttpServer`
  imitating that API, never against the real API.
- Default form-binding errors (`typeMismatch`) return technical text. Resolve messages
  through the `MessageSource`.
