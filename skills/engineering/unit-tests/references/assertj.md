# AssertJ reference

Only use AssertJ if `org.assertj:assertj-core` is already a dependency of the module — don't add
it just to write one test unless the user asks for it.

## Why prefer it over JUnit's own assertions

- `assertThat(actual).isEqualTo(expected)` reads left-to-right and can't have its arguments
  swapped by mistake — `Assertions.assertEquals(expected, actual)` can, and a swapped pair
  produces a confusing failure message ("expected: <real value> but was: <expected value>").
- Chained assertions on the same object read as one coherent check instead of several separate
  `assertX` calls:
  ```java
  assertThat(beneficiario)
      .isNotNull()
      .extracting(Beneficiario::getCidade, Beneficiario::getEstado)
      .containsExactly("Fortaleza", "CE");
  ```
- Failure messages are generally more specific out of the box (collection diffs, field-by-field
  object comparison, etc.).

## Patterns worth knowing

- **`.as("description")`** — add context when the assertion alone wouldn't explain *why* it
  matters: `assertThat(response.getStatus()).as("status after retry").isEqualTo(200);`
- **`assertThatThrownBy(() -> subject.doThing())`** — fluent exception testing without a
  try/catch, chainable with `.isInstanceOf(...)`, `.hasMessageContaining(...)`:
  ```java
  assertThatThrownBy(() -> service.buscarPorCpf(null))
      .isInstanceOf(IllegalArgumentException.class)
      .hasMessageContaining("cpf");
  ```
- **`.extracting(...)`** — pull one or more fields out of an object/collection before asserting,
  instead of writing several `assertThat(obj.getX())` lines.
- **Collections:** `containsExactly` (order matters) vs `containsExactlyInAnyOrder` (order
  doesn't) vs `contains` (subset, order doesn't matter) — pick the one that actually matches what
  the behavior guarantees; using the loosest one that happens to pass hides a real ordering bug.
- **Custom/domain assertions** — worth writing (a small `BeneficiarioAssert extends
  AbstractAssert<...>`) only once a domain object's checks are repeated across many tests; don't
  build one preemptively for a single test.

## Consistency

If a module already has some tests using plain JUnit assertions and some using AssertJ, follow
whichever is more common in that module rather than mixing further — don't introduce a third
style. Flag the inconsistency to the user if it seems worth cleaning up, but that's a separate
task from writing the test at hand.
