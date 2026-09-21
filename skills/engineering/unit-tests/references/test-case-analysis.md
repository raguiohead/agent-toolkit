# Deciding what tests are needed

The question "what tests does this class need?" has a systematic answer — it doesn't require
guessing or a fixed quota ("write 5 tests per method"). Walk the code and derive the test list
from what's actually there.

## The procedure

### 1. Read before writing

Read the whole class under test, and the **interface** (method signatures, return types, thrown
exceptions) of anything it depends on — not their implementations, that's a different class's
concern. If the class has an existing test file, read that too, in full, before deciding what's
missing (see Section 5).

### 2. Enumerate branch points

Go method by method (public and package-private methods reachable from the class's public API —
skip private helpers, see Section 6) and list every point where execution can go two different
ways:

- `if` / `else if` / `else`
- `switch` / `case` (including the default case)
- Ternary expressions (`cond ? a : b`)
- Short-circuit boolean logic (`a && b`, `a || b`) — each operand that can independently flip the
  result is its own branch
- `try`/`catch` — each distinct caught exception type is a branch, and so is the case where no
  exception occurs
- Early returns / guard clauses
- Loops — at minimum: zero iterations (empty collection), one iteration, and "many" if the logic
  treats a single item differently from a collection

**This list's size is a lower bound on the number of test cases needed for that method** — a
method with four independent branches needs at least four tests to exercise all of them, not one
"happy path" test plus a vague sense that "the rest is probably fine."

### 3. Enumerate collaborator outcomes

For every mocked dependency the method calls, list the outcomes that would make the method behave
differently — not just "call it once and check it doesn't blow up":

- A repository/finder: value present vs. `Optional.empty()`/`null` vs. multiple results (if the
  method's own logic branches on that — e.g. `IncorrectResultSizeDataAccessException` when a
  query expected to be unique returns more than one row) vs. throwing.
- A client/gateway call: success vs. a specific exception it's documented to throw (timeout,
  4xx/5xx mapped to a domain exception) — one test per outcome the method actually handles
  differently.
- Anything the method calls conditionally (only when a prior check passes) — a test that
  exercises the branch where it's *not* called, asserting `verify(mock, never())...`, is often
  missing and is a real gap.

### 4. Equivalence partitioning + boundary values

Don't enumerate every possible input value — group them into classes that the method treats the
same way, then test one representative per class plus the boundaries:

- Example: a method validating a CPF. Equivalence classes: "well-formed and valid", "well-formed
  but check-digit invalid", "wrong length", "null". Boundaries worth a dedicated test: empty
  string, exactly-one-digit-short, exactly-one-digit-long — but only if the method's own logic
  actually treats length as a boundary (e.g. a length check before parsing). Don't invent a
  boundary the code doesn't have.
- Example: a method that behaves differently for an empty vs. non-empty `List` parameter —
  boundaries are 0, 1, and "more than 1" only if the method's logic distinguishes singular from
  plural (e.g. picks the first element specially, or requires uniqueness).

### 5. Gap analysis against an existing test file

If `XyzServiceTest.java` already exists, don't start from zero:

1. List the test methods already there and, for each, which branch/collaborator-outcome/
   equivalence-class from Sections 2-4 it already covers.
2. Diff that against the full list derived in Sections 2-4.
3. Add tests only for what's missing. If an existing test looks wrong (asserts the wrong thing,
   or its name doesn't match what it actually checks), flag it to the user rather than silently
   rewriting it, unless they've already asked you to fix the test file itself.

### 6. What NOT to test

- Getters/setters and other Lombok-generated code with no logic in them.
- Private or package-private helper methods that have no branch of their own beyond what's
  already exercised through the public method that calls them — test them indirectly via that
  public method's test cases, not directly (Java can't call a private method from a test anyway
  without reflection, which is itself a sign the test is at the wrong level).
- A getter-only DTO/record with no validation or derived logic.

Don't chase 100% line/branch coverage as a goal in itself, either — the procedure above already
converges on covering everything meaningfully reachable; a coverage percentage is a side effect
of doing this correctly, not a separate target to hit by padding with low-value tests.

## Worked example

```java
public BeneficiarioDTO buscarPorCpf(String cpf) {
    if (cpf == null || cpf.isBlank()) {
        throw new IllegalArgumentException("cpf não pode ser vazio");
    }

    Optional<Beneficiario> beneficiario = repository.findByCpf(cpf);

    if (beneficiario.isEmpty()) {
        throw new BeneficiarioNaoEncontradoException(cpf);
    }

    return mapper.toDTO(beneficiario.get());
}
```

Applying the procedure:

- **Branch points (Section 2):** the `null`/blank guard (2 sub-cases: null, blank — decide if
  they need separate tests or one parameterized test, since they hit the same branch and same
  exception type, one parameterized test covering both is enough), the `isEmpty()` check (2
  branches: empty → exception, present → continue).
- **Collaborator outcomes (Section 3):** `repository.findByCpf` returns present vs. empty —
  already captured by the branch above. `mapper.toDTO` isn't conditional here, so one test
  exercising the happy path covers it; no extra case needed unless the mapper itself can throw.
- **Equivalence classes (Section 4):** valid non-blank CPF (→ happy path), null CPF, blank CPF
  (empty string / whitespace-only — same equivalence class as null for this method, since both
  hit the same guard and throw the same exception).

Resulting minimum test list:
1. `deveRetornarDTOQuandoBeneficiarioExiste` — valid CPF, repository returns present, asserts the
   mapped DTO.
2. `deveLancarExcecaoQuandoBeneficiarioNaoExiste` — valid CPF, repository returns empty, asserts
   `BeneficiarioNaoEncontradoException` with that CPF.
3. `deveLancarExcecaoQuandoCpfNuloOuVazio` (parameterized over `null` and `""`) — asserts
   `IllegalArgumentException`, and that `repository.findByCpf` is **never** called (the guard
   short-circuits before reaching the collaborator).

Three tests, each traceable to a specific branch or collaborator outcome — not a number picked in
advance.
