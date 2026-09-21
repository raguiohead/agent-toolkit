# Spring Boot Test reference

## Pick the narrowest slice that exercises the behavior

| Slice | Loads | Use for |
|---|---|---|
| Plain JUnit + Mockito (no Spring annotations at all) | Nothing — just the class under test with its dependencies mocked | Services, mappers, validators, anything with constructor-injected dependencies you can mock directly. **This should be the default for most business-logic classes** — it's the fastest and most focused. |
| `@WebMvcTest(SomeController.class)` | MVC infrastructure + the named controller(s) only (`@Controller`, `@ControllerAdvice`, converters, filters, interceptors) | Testing a controller's request mapping, validation, status codes, and JSON (de)serialization, with services mocked out. |
| `@DataJpaTest` | JPA/Data JPA layer, an embedded/test datasource, entity scanning and repositories | Repository queries, custom `@Query` methods, projections (e.g. a typed `interface XyzProjection` backed by a view). Transactional and rolled back after each test by default. |
| `@SpringBootTest` | The full application context (all beans, config, embedded servlet container if `webEnvironment` requires it) | True end-to-end/integration tests spanning multiple layers (e.g. controller → service → repository against a real-ish datasource). Slowest option — don't reach for it as the default. |

Prefer the narrower slice whenever the behavior under test doesn't actually need the rest of the
context wired up. A suite of only `@SpringBootTest` tests tends to get slow enough that tests
start getting skipped, disabled, or deleted rather than fixed.

## Mocking a Spring bean inside a slice test

**Check the project's Spring Boot version first** (parent/BOM version in `pom.xml` or
`build.gradle`):

- **Spring Boot >= 3.4:** use `@MockitoBean` / `@MockitoSpyBean` (package
  `org.springframework.test.context.bean.override.mockito`). `@MockBean`/`@SpyBean` are
  deprecated as of 3.4 and scheduled for removal in Spring Boot 4.0 — don't introduce new usages
  of them in a project already on >= 3.4, even if older tests in the same repo still use them.
- **Spring Boot < 3.4:** `@MockBean`/`@SpyBean` (package `org.springframework.boot.test.mock.mockito`)
  are the only option and are not yet deprecated at that version — use them, don't backport
  `@MockitoBean` into a version that predates it.
- **Migrating existing `@MockBean` usages is not a mechanical 1:1 swap** — `@MockitoBean` is not
  supported on `@Configuration` or `@Component` classes the way `@MockBean` was. If asked to
  migrate a batch of tests, check each usage compiles and behaves the same after the swap, don't
  assume.

```java
@WebMvcTest(BeneficiarioController.class)
class BeneficiarioControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean // or @MockBean on Spring Boot < 3.4
    private BeneficiarioService service;

    @Test
    void deveRetornar404QuandoBeneficiarioNaoExiste() throws Exception {
        when(service.buscarPorCpf("12345678900")).thenReturn(Optional.empty());

        mockMvc.perform(get("/v1/beneficiarios/12345678900"))
            .andExpect(status().isNotFound());
    }
}
```

## `@DataJpaTest` notes

- Rolls back the transaction after each test by default — don't add manual cleanup unless a test
  explicitly disables that (`@Transactional(propagation = ...)` or `@Rollback(false)`) for a
  reason.
- By default replaces the real datasource with an embedded one unless
  `@AutoConfigureTestDatabase(replace = Replace.NONE)` is used — check which the project intends
  before assuming either way, especially for tests against Oracle-specific SQL/views (e.g. a
  `VW_WS_BENEFICIARIO`-style view) that an embedded H2 database won't actually have.
- For a typed projection interface (`interface XyzProjection { String getCidade(); ... }` backed
  by a repository method), test it like any other repository method: seed the minimum rows needed
  via `TestEntityManager`, call the repository method, assert on the projection's accessor
  methods with AssertJ.
