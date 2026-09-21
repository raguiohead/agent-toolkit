# JUnit reference

## Version check

- **JUnit 5 (Jupiter):** artifacts under group `org.junit.jupiter` (`junit-jupiter-api`,
  `junit-jupiter-engine`, `junit-jupiter-params`), typically managed via the
  `org.junit:junit-bom` import in Maven/Gradle.
- **JUnit 6:** the framework was rebranded/consolidated (`junit-team/junit-framework`); recent GA
  line is 6.1.x. Mostly source-compatible with JUnit 5 code (same `org.junit.jupiter.api`
  annotations for day-to-day test writing), but check the project's actual pinned version before
  relying on anything 6-specific — notable 6.x additions include `@DefaultLocale`/
  `@DefaultTimeZone` built-in extensions, native Kotlin coroutine support (`suspend` test/
  lifecycle methods without `runBlocking`), and JSpecify null-safety annotations across the API.
  If in doubt, re-check https://docs.junit.org/ for the pinned version rather than assuming.

## Core annotations

- `@Test` — a test method.
- `@BeforeEach` / `@AfterEach` — per-test setup/teardown.
- `@BeforeAll` / `@AfterAll` — per-class setup/teardown (must be `static` unless the test class
  uses `@TestInstance(Lifecycle.PER_CLASS)`).
- `@Nested` — group related tests in an inner class, useful for "different states of the same
  subject" (e.g. `class WhenAccountIsEmpty { ... }` nested inside the outer test class).
- `@DisplayName` — human-readable name for reports; use to clarify, not to replace a good method
  name.
- `@Disabled("reason")` — always give a reason; never leave a test silently skipped without one.

## Parameterized tests

Prefer these over near-duplicate test methods that only vary input/expected values:

```java
@ParameterizedTest
@CsvSource({
    "12345678900, true",
    "00000000000, false",
})
void deveValidarCpf(String cpf, boolean esperado) {
    assertThat(validador.isValido(cpf)).isEqualTo(esperado);
}
```

- `@ValueSource` — a single primitive/String argument per case.
- `@CsvSource` / `@CsvFileSource` — multiple arguments per case, inline or from a file.
- `@MethodSource` — when arguments are objects that don't fit in a CSV literal (build them in a
  `static Stream<Arguments>` method).
- `@EnumSource` — iterate every (or a filtered subset of) enum constant.

## Assertions and exceptions

- `Assertions.assertThrows(SomeException.class, () -> subject.doThing())` — always assert the
  concrete exception type, and capture the return value if you need to assert on the exception's
  message/fields too:
  ```java
  var ex = assertThrows(IncorrectResultSizeDataAccessException.class, () -> repo.findByCpf(cpf));
  assertThat(ex.getMessage()).contains("2 results were returned");
  ```
- Prefer AssertJ (`references/assertj.md`) over `Assertions.assertEquals`/`assertTrue` when it's
  already a project dependency — see Section 4 of `SKILL.md` for why.

## Lifecycle gotcha

`@TestInstance(Lifecycle.PER_CLASS)` changes `@BeforeAll`/`@AfterAll` to non-static and lets state
persist across test methods in the same class — useful for expensive shared fixtures, but it also
means tests in that class are no longer fully isolated from each other. Don't reach for it just
to avoid making a setup method `static`; only use it when sharing that state is intentional.
