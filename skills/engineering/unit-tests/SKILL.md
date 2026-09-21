---
name: unit-tests
description: >
  Writes and reviews Java unit tests (JUnit, Mockito, AssertJ, Spring Boot Test slices).
  Before writing anything, systematically derives *which* test cases a class/method actually
  needs — branch enumeration, collaborator-outcome enumeration, equivalence partitioning and
  boundary values, plus a gap analysis against any existing test file — instead of guessing at
  "happy path plus a couple of edge cases." Detects the actual test stack of the project at hand
  (JUnit 5 vs 6, Mockito version, whether AssertJ is available, Spring Boot version and therefore
  @MockBean vs @MockitoBean) from its pom.xml/build.gradle instead of assuming one — then follows
  that project's own existing test conventions (naming, package layout, AAA vs given/when/then)
  before falling back to the defaults in this skill's references. Use whenever the user asks to
  write/add/create unit tests for a Java class, decide what tests a class needs, review or fix
  existing Java tests, increase test coverage, mock a dependency with Mockito, or write a Spring
  Boot slice test (@WebMvcTest/@DataJpaTest/@SpringBootTest).
---

# unit-tests

Writes and reviews Java unit tests. The one rule that overrides everything else here: **read the
project before writing anything** — its build file tells you the real stack, and its existing
tests tell you the real conventions. This skill's references are a fallback for decisions the
project doesn't already make, not a template to impose over what's there.

## 1 — Detect the stack before writing a single test

Read the build file (`pom.xml` or `build.gradle`/`build.gradle.kts`) for the module under test:

| Signal | What it tells you |
|---|---|
| `org.junit.jupiter:junit-jupiter*` version | JUnit 5.x — see `references/junit.md` |
| `org.junit:junit-jupiter*` / `junit-platform` 6.x, or a parent that pins JUnit 6 | JUnit 6.x — mostly source-compatible with 5, but check `references/junit.md` for what's new/changed before relying on it |
| `org.mockito:mockito-core`/`mockito-junit-jupiter` version | Mockito available — see `references/mockito.md` |
| `org.assertj:assertj-core` present | AssertJ available and expected — prefer it over raw `Assertions.assertEquals` (see `references/assertj.md`) |
| No AssertJ dependency | Stick to JUnit's own `Assertions.*` — don't add a new dependency to write a test unless asked |
| `spring-boot-starter-parent`/`spring-boot-dependencies` version | If **>= 3.4**, prefer `@MockitoBean`/`@MockitoSpyBean`; if **< 3.4**, use `@MockBean`/`@SpyBean` (the only option, and not yet deprecated) — see `references/spring-boot-test.md` |

Then look at 2-3 existing test files in the same module (or the closest equivalent) for:
- Naming convention (`shouldXWhenY`, `methodName_condition_expected`, `deve...quando...`, etc.)
- Package layout (mirrors `src/main` under `src/test`?)
- Assertion style already in use, test-class suffix (`*Test`, `*Tests`, `*IT`/`*IntegrationTest`
  for a separate integration-test naming scheme)
- Whether there's a shared base test class or common fixture/builder pattern already established

**Match what's already there.** Only reach for this skill's own defaults (Section 2 onward, and
the `references/` files) when the project gives no signal — e.g. it's the first test in a new
module, or the user is asking for a kind of test the project hasn't written yet (its first
`@DataJpaTest`, say).

## 2 — Deciding what tests are needed (do this before writing any test)

Given a class or method to test, don't rely on a feel for "happy path plus a couple of edge
cases" — walk the code systematically so nothing gets missed. Full method and a worked example in
`references/test-case-analysis.md`; short version:

1. **Read the whole method/class first**, and the interface (not implementation) of anything it
   depends on. You can't enumerate branches you haven't seen.
2. **List every branch point**: `if`/`else`, `switch`/`case`, ternaries, short-circuit `&&`/`||`,
   `catch` blocks, early returns, loop zero/one/many iterations. Each one is a candidate test
   case — the branch count is a lower bound on how many tests are needed, not "one happy-path
   test is enough."
3. **List every distinct outcome a mocked collaborator can produce that changes behavior**
   (repository returns a value / returns empty / throws) — each is its own candidate test case,
   not just "the mock returns something."
4. **Group inputs into equivalence classes, then add boundary values.** Don't test every possible
   CPF — test one valid representative, one invalid representative, and the boundaries that
   actually matter for this method (`null`, empty string, wrong length), only where the method's
   own logic treats them differently.
5. **Cover every outcome the method itself can produce**: each distinct return value/type, each
   exception it can throw, each side-effect call it makes to another collaborator (a save, a
   publish, a call to another service).
6. **If a test file already exists for the class, read it first and do a gap analysis** — list
   what it already covers, then add only what's missing. Don't re-derive coverage from scratch
   and duplicate what's there.
7. **Skip**: trivial getters/setters/Lombok-generated code, and private/package-private helpers
   not reachable except through an already-covered public method.

Only once this list of cases exists, write the actual test methods, following the naming/
structure defaults in Section 3.

## 3 — Test structure and naming (default, when the project has no convention yet)

- One behavior per test method. If you need "and" to describe what a test checks, split it.
- Arrange-Act-Assert, with a blank line between each section for a test of any complexity.
- Name tests so a failure is legible from the method name alone: `should<ExpectedResult>When
  <Condition>` or `<method>_<condition>_<expectedResult>` are both fine — pick one and use it
  consistently within a class. Add `@DisplayName` when the method name still isn't clear enough
  in a test report, not as a substitute for a good method name.
- Cover: the happy path, each meaningfully distinct edge case (empty/null/boundary input), and
  the error/exception path for anything that can throw. Don't write a test for a trivial getter/
  setter with no logic, and don't chase 100% line coverage as a goal in itself — a test that
  doesn't assert a real behavior isn't worth adding just to move a coverage number.
- Prefer `@ParameterizedTest` (`@ValueSource`, `@CsvSource`, `@MethodSource`) over copy-pasted
  near-identical test methods that only vary the input/expected pair.

## 4 — Mocking (Mockito)

See `references/mockito.md` for the full guide. The two rules worth repeating here because
they're the most common mistake:

- **Only mock types your team owns** (services, repositories, gateways/clients you wrote).
  Mocking a JDK type (`List`, `Map`, `String`) or an unowned third-party type produces a test
  that can't actually catch a real integration break — wrap the third-party call in your own
  interface if you need to isolate it.
- **Don't over-mock.** If a test needs five mocks to exercise one method, that's usually a sign
  the method (or the class) is doing too much, not that the test needs more setup.

## 5 — Assertions (AssertJ, when available)

See `references/assertj.md`. Prefer `assertThat(actual).isEqualTo(expected)` fluent chains over
JUnit's `assertEquals(expected, actual)` — argument order mistakes are a real, recurring bug
class with the JUnit form, and AssertJ's chained style also gives better failure messages and
groups related assertions on the same object. Use `.as("context")` when the default failure
message wouldn't make the cause obvious. Always assert on the specific exception type, not just
"an exception was thrown."

## 6 — Spring Boot test slices

See `references/spring-boot-test.md`. Default to the narrowest slice that exercises the
behavior under test — `@WebMvcTest` for a single controller, `@DataJpaTest` for a
repository/projection, plain Mockito (no Spring context at all) for a service with its
dependencies mocked. Reach for `@SpringBootTest` (full context) only when the test genuinely
needs multiple layers wired together — it's slower, and slower tests get skipped or deleted
over time.

## 7 — Language

Match whatever language the surrounding test suite/comments use (this team's Java code and test
names are often in Portuguese, e.g. `deveRetornarErroQuandoCpfDuplicado`) — don't switch a
project from Portuguese test names to English ones or vice versa mid-suite.

## 8 — If something here looks outdated

JUnit/Mockito/AssertJ/Spring Boot all ship fairly often. If a project's dependency versions look
newer than what's described in `references/`, or the user mentions something that contradicts
this skill (a new annotation, a deprecation), treat the project's actual `pom.xml`/`build.gradle`
and official docs as the source of truth — search the web for the current guidance rather than
following a stale note here, and flag the discrepancy so these references can be updated.
