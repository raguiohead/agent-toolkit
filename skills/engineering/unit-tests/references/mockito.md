# Mockito reference

## Setup

Prefer the annotation-based setup with the JUnit 5 extension over manual
`Mockito.mock(...)`/`MockitoAnnotations.openMocks(this)` calls:

```java
@ExtendWith(MockitoExtension.class)
class BeneficiarioServiceTest {

    @Mock
    private BeneficiarioRepository repository;

    @InjectMocks
    private BeneficiarioService service;

    @Test
    void deveRetornarBeneficiarioQuandoCpfExiste() {
        when(repository.findByCpf("12345678900")).thenReturn(Optional.of(beneficiario));

        var resultado = service.buscarPorCpf("12345678900");

        assertThat(resultado).isPresent();
        verify(repository).findByCpf("12345678900");
    }
}
```

## Rules, in priority order

1. **Only mock types you own.** Services, repositories, gateways/clients written by the team are
   fair game. Don't mock `List`, `Map`, `String`, or a third-party SDK class directly — if you
   need to isolate a third-party call, wrap it behind your own interface and mock that instead.
   A test that mocks code you don't own can't catch a real break when that dependency changes
   behavior (the mock stays "correct" even after the real API changed).
2. **Don't over-mock.** If a single test needs many mocks wired together to exercise one method,
   that's usually telling you the method/class under test is doing too much — consider whether
   the production code should be split, rather than adding more mock setup to cope with it.
3. **Verify with the most specific matcher that's true**, not the loosest one that passes:
   `verify(repository, times(1)).save(any())` over `verify(repository, atLeastOnce()).save(any())`
   when you actually expect exactly one call. Loose verifications hide regressions where a method
   starts being called an extra time.
4. **Use `ArgumentCaptor`** when you need to assert on *what* was passed to a mock, not just that
   it was called:
   ```java
   var captor = ArgumentCaptor.forClass(BeneficiarioDTO.class);
   verify(urbisClient).enviar(captor.capture());
   assertThat(captor.getValue().getEstado()).isEqualTo("CE");
   ```
5. **Use `@Spy`** only for partial mocking of a real object (calling through to real methods
   except the one(s) you stub) — if you find yourself reaching for `@Spy` often, that's usually a
   sign the class needs to be split so the part you want "real" and the part you want faked are
   separate collaborators.
6. **Never use `Thread.sleep()`** to wait for async behavior in a test — it's slow and flaky by
   construction. Use `Awaitility` (`await().atMost(...).until(...)`) or make the async boundary
   itself mockable/synchronous in the test.
7. **Strict stubbing is the default** in recent Mockito (`UnnecessaryStubbingException` if a
   `when(...)` is never used) — don't work around it with `lenient()` unless the stub is
   genuinely conditionally used across parameterized cases; an unused stub is usually a sign the
   test is asserting less than it thinks it is.

## Spring Boot context

When the test loads a Spring context (`@WebMvcTest`, `@SpringBootTest`, etc.) and needs to mock a
bean rather than a plain constructor dependency, use `@MockitoBean`/`@MockitoSpyBean` (Spring
Boot >= 3.4) or `@MockBean`/`@SpyBean` (older) — see `references/spring-boot-test.md`. Don't use
plain Mockito `@Mock` for a bean that needs to be injected into the Spring context itself.
