# unit-tests

Writes and reviews Java unit tests (JUnit, Mockito, AssertJ, Spring Boot Test slices). Detects the
project's actual stack (JUnit 5 vs 6, Mockito, AssertJ availability, Spring Boot version and
therefore `@MockBean` vs `@MockitoBean`) from its `pom.xml`/`build.gradle` and follows the
project's own existing test conventions before falling back to this skill's defaults.

- [`SKILL.md`](./SKILL.md) — stack-detection step, structure/naming defaults, and pointers into
  each reference file.
- [`references/test-case-analysis.md`](./references/test-case-analysis.md) — the method for
  deciding *what* tests a class/method needs: branch enumeration, collaborator-outcome
  enumeration, equivalence partitioning + boundary values, gap analysis against an existing test
  file, and a worked example.
- [`references/junit.md`](./references/junit.md) — JUnit 5/6 annotations, parameterized tests,
  exception assertions, lifecycle gotchas.
- [`references/mockito.md`](./references/mockito.md) — mocking rules (what to mock, over-mocking,
  verification specificity, ArgumentCaptor, spies, strict stubbing).
- [`references/assertj.md`](./references/assertj.md) — fluent assertion patterns and when to
  prefer AssertJ over JUnit's own assertions.
- [`references/spring-boot-test.md`](./references/spring-boot-test.md) — slice-test decision
  table (`@WebMvcTest`/`@DataJpaTest`/`@SpringBootTest`) and the `@MockBean`→`@MockitoBean`
  migration caveat.

**No cross-plugin dependency** — self-contained, works in any Java repo with this plugin
installed.
